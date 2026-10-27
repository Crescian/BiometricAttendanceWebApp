<?php

namespace App\Http\Middleware;

use App\Services\AuditLogger;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;

/**
 * Audit safety net, placed around CSRF and the route middleware so it also sees their rejections.
 *
 * - Every denied request (401, 403, 419) is recorded.
 * - Every file download (routes named download.*) is recorded.
 * - Every state-changing request (POST/PUT/PATCH/DELETE) that did not already write its own,
 *   more specific audit entry is recorded with its route, sanitized input and response status,
 *   so a new endpoint can never change data without leaving a trace.
 */
class AuditRequests
{
    /** POST endpoints that only read data (DataTables fetches, lookups). */
    private const READ_ONLY_ROUTES = ['employees.fetchs', 'upload.exist'];

    private const READ_ONLY_PATHS = ['get-entry-dates'];

    public function handle(Request $request, Closure $next)
    {
        $response = $next($request);

        try {
            $this->audit($request, $response);
        } catch (\Throwable $e) {
            report($e); // AuditLogger keeps its own fallback; never break the response over this
        }

        return $response;
    }

    private function audit(Request $request, Response $response): void
    {
        $status = $response->getStatusCode();
        $route = $request->route()?->getName() ?? $request->path();
        $line = $request->method().' /'.ltrim($request->path(), '/')." → {$status}";

        if (in_array($status, [401, 403, 419], true)) {
            AuditLogger::record(match ($status) {
                401 => 'access.unauthenticated',
                403 => 'access.forbidden',
                419 => 'access.csrf_rejected',
            }, [
                'category' => 'access',
                'action' => 'deny',
                'outcome' => 'denied',
                'description' => match ($status) {
                    401 => "Request rejected: not signed in ({$line})",
                    403 => "Access denied: insufficient permission ({$line})",
                    419 => "Request rejected: session expired or invalid CSRF token ({$line})",
                },
                'metadata' => ['status' => $status, 'input' => $this->input($request)],
            ]);

            return;
        }

        if ($request->isMethod('GET') && Str::startsWith((string) $route, 'download.') && $status === 200) {
            $file = method_exists($response, 'getFile') ? $response->getFile() : null;
            AuditLogger::record('access.file_downloaded', [
                'category' => 'access',
                'action' => 'download',
                'description' => 'Downloaded '.($file ? $file->getFilename() : $route),
                'metadata' => array_filter([
                    'file' => $file?->getFilename(),
                    'bytes' => $file?->getSize(),
                    'sha256' => $file && $file->isReadable() ? hash_file('sha256', $file->getPathname()) : null,
                ]),
            ]);

            return;
        }

        if (! in_array($request->method(), ['POST', 'PUT', 'PATCH', 'DELETE'], true)
            || $request->attributes->get('audit.recorded')
            || in_array($route, self::READ_ONLY_ROUTES, true)
            || in_array(trim($request->path(), '/'), self::READ_ONLY_PATHS, true)) {
            return;
        }

        AuditLogger::record('http.'.strtolower($request->method()), [
            'category' => 'data',
            'action' => strtolower($request->method()),
            'outcome' => match (true) {
                $status >= 500 => 'failure',
                $status >= 400 => 'failure',
                default => 'success',
            },
            'description' => "Request {$line}",
            'metadata' => ['status' => $status, 'input' => $this->input($request)],
        ]);
    }

    /** Input with secrets redacted (by AuditLogger), long values cut, and uploads summarized. */
    private function input(Request $request): array
    {
        $summarize = function ($value) use (&$summarize) {
            if ($value instanceof UploadedFile) {
                return [
                    'file' => $value->getClientOriginalName(),
                    'bytes' => $value->getSize(),
                    'sha256' => $value->isValid() ? hash_file('sha256', $value->getRealPath()) : null,
                ];
            }
            if (is_array($value)) {
                $items = array_slice($value, 0, 50, true);
                $out = array_map($summarize, $items);
                if (count($value) > 50) {
                    $out['…'] = (count($value) - 50).' more';
                }

                return $out;
            }

            return is_string($value) ? Str::limit($value, 200) : $value;
        };

        return $summarize(array_merge(
            $request->except(['_token', '_method', 'password', 'password_confirmation', 'current_password']),
            $request->allFiles()
        ));
    }
}
