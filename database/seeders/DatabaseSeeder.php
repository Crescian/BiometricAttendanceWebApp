<?php

namespace Database\Seeders;

// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     *
     * @return void
     */
    public function run()
    {
        // \App\Models\User::factory(10)->create();

        // \App\Models\User::factory()->create([
        //     'name' => 'Test User',
        //     'email' => 'test@example.com',
        // ]);

        // Seed test employee data for testing export functionality
        \App\Models\EmployeeManagement::create([
            'unique_id' => 'TMNG-202502-419',
            'employee_name' => 'RABINA, JOESEL CASTILLO',
            'basic_salary' => '500',
            'schedule' => '7-4'
        ]);

        \App\Models\EmployeeManagement::create([
            'unique_id' => 'TMNG-202502-420',
            'employee_name' => 'TEST, EMPLOYEE TWO',
            'basic_salary' => '600',
            'schedule' => '8-5'
        ]);
    }
}
