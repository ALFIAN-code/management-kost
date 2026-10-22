<?php

namespace Modules\Finance\database\seeders;

use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Modules\Auth\Models\User;
use Modules\Finance\Enums\FineStatus;
use Modules\Finance\Enums\InvoiceStatus;
use Modules\Finance\Enums\PaymentStatus;
use Modules\Finance\Models\Fine;
use Modules\Finance\Models\Invoice;
use Modules\Finance\Models\Payment;

class FineSeeder extends Seeder
{
    /**
     * Skenario denda realistis untuk demo Wisma Amal Gorontalo:
     * - Beberapa denda sudah lunas (dengan invoice & payment)
     * - Beberapa denda masih unpaid
     * - Satu denda dimaafkan (waived)
     * - Satu denda dibatalkan (cancelled)
     */
    public function run(): void
    {
        $users = User::whereHas('roles', fn ($q) => $q->whereIn('name', ['member', 'resident']))->get();

        if ($users->isEmpty()) {
            $this->command->warn('No users with the member or resident role. Run UserSeeder first.');

            return;
        }

        $now = Carbon::now();

        $templates = [
            ['reason' => 'Making noise at night (after 22.00)', 'amount' => 50_000],
            ['reason' => 'Staying over a guest without permission from the manager', 'amount' => 100_000],
            ['reason' => 'Littering in the corridor area', 'amount' => 25_000],
            ['reason' => 'Returning the spare key late', 'amount' => 30_000],
            ['reason' => 'Smoking inside the room (non-smoking zone)', 'amount' => 150_000],
            ['reason' => 'Damaging bathroom facilities (the faucet is damaged)', 'amount' => 200_000],
            ['reason' => 'Exceeding the electricity limit (cooking in the room)', 'amount' => 75_000],
            ['reason' => 'Missing the resident meeting without notice', 'amount' => 20_000],
            ['reason' => 'Bringing pets into the room', 'amount' => 100_000],
            ['reason' => 'Hanging laundry in a prohibited area (the main balcony)', 'amount' => 15_000],
        ];

        $seq = 1;

        foreach ($users->take(10) as $index => $user) {
            $template = $templates[$index % count($templates)];
            $createdAt = $now->copy()->subDays(rand(3, 60));

            // Tentukan status berdasarkan index untuk variasi realistis
            $status = match (true) {
                $index < 4 => FineStatus::PAID,
                $index === 4 => FineStatus::WAIVED,
                $index === 5 => FineStatus::CANCELLED,
                default => FineStatus::UNPAID,
            };

            $fine = Fine::create([
                'tenant_user_id' => $user->id,
                'schedule_id' => null,
                'amount' => $template['amount'],
                'reason' => $template['reason'],
                'status' => $status->value,
                'waive_reason' => $status === FineStatus::WAIVED
                    ? 'The resident apologized in person and promised not to repeat it.'
                    : null,
                'paid_at' => $status === FineStatus::PAID ? $createdAt->copy()->addDays(rand(1, 5)) : null,
                'created_at' => $createdAt,
                'updated_at' => $createdAt,
            ]);

            // Buat invoice + payment untuk denda yang lunas
            if ($status === FineStatus::PAID) {
                $paidAt = $createdAt->copy()->addDays(rand(1, 5));
                $suffix = strtoupper(substr(md5($fine->id.$seq), 0, 6));
                $invoiceNumber = 'FINE-'.$createdAt->format('Ymd').'-'.str_pad($user->id, 4, '0', STR_PAD_LEFT).'-'.$suffix;

                $invoice = Invoice::create([
                    'type' => 'fine',
                    'invoice_number' => $invoiceNumber,
                    'amount' => $fine->amount,
                    'status' => InvoiceStatus::PAID->value,
                    'due_date' => $createdAt->copy()->addDays(7)->toDateString(),
                    'tenant_user_id' => $user->id,
                    'tenant_name' => $user->name,
                    'tenant_phone' => $user->phone_number,
                    'created_at' => $createdAt,
                    'updated_at' => $paidAt,
                ]);

                DB::table('fine_invoice')->insert([
                    'fine_id' => $fine->id,
                    'invoice_id' => $invoice->id,
                    'created_at' => $createdAt,
                    'updated_at' => $createdAt,
                ]);

                Payment::create([
                    'invoice_id' => $invoice->id,
                    'payment_method' => 'manual',
                    'payment_proof_path' => 'proofs/bukti_transfer_sample.jpg',
                    'status' => PaymentStatus::VERIFIED->value,
                    'admin_notes' => null,
                    'created_at' => $paidAt,
                    'updated_at' => $paidAt->copy()->addHours(rand(1, 3)),
                ]);
            }

            $seq++;
        }

        $count = Fine::count();
        $this->command->info("FineSeeder finished: {$count} fine records created successfully.");
    }
}
