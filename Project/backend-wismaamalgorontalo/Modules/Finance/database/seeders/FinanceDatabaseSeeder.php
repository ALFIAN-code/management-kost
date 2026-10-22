<?php

namespace Modules\Finance\database\seeders;

use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Modules\Finance\Enums\InvoiceStatus;
use Modules\Finance\Enums\PaymentStatus;
use Modules\Finance\Models\Expense;
use Modules\Finance\Models\Invoice;
use Modules\Finance\Models\Payment;
use Modules\Schedule\Models\Schedule;

class FinanceDatabaseSeeder extends Seeder
{
    /**
     * Skenario seeder yang realistis untuk Wisma Amal Gorontalo:
     * - Invoice 6 bulan historis untuk semua lease aktif (data grafik dashboard)
     * - Invoice bulan ini: sebagian lunas, sebagian masih outstanding/overdue
     * - Beberapa payment masih pending (menunggu verifikasi admin)
     * - Satu payment pernah ditolak (rejected)
     * - Data pengeluaran operasional 6 bulan terakhir yang beragam & realistis
     */
    public function run(): void
    {
        $schedules = Schedule::with('room')->where('type', 'sewa')->get();

        if ($schedules->isEmpty()) {
            $this->command->warn('No lease schedule data found. Run DummyDataSeeder first.');

            return;
        }

        $this->seedInvoicesAndPayments($schedules);
        $this->seedExpenses();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // INVOICE & PAYMENT
    // ─────────────────────────────────────────────────────────────────────────

    private function seedInvoicesAndPayments($schedules): void
    {
        $now = Carbon::now();
        $invoiceSeq = 1;

        foreach ($schedules as $schedule) {
            $amount = (int) ($schedule->agreed_price ?? 500000);

            // ── A. SCHEDULE AKTIF: buat 6 bulan historis + bulan ini ──────────
            if ($schedule->status->value === 'active') {

                // 5 bulan ke belakang – semua LUNAS dengan payment VERIFIED
                for ($monthsAgo = 5; $monthsAgo >= 1; $monthsAgo--) {
                    $baseDate = $now->copy()->subMonths($monthsAgo)->startOfMonth()->addDays(rand(1, 5));
                    $dueDate = $baseDate->copy()->addDays(10);
                    $paidAt = $baseDate->copy()->addDays(rand(1, 9));
                    $method = $this->randomMethod();

                    $invoiceNumber = $this->invoiceNumber($baseDate, $invoiceSeq++);
                    $invoice = Invoice::updateOrCreate(
                        ['invoice_number' => $invoiceNumber],
                        [
                            'schedule_id' => $schedule->id,
                            'amount' => $amount,
                            'status' => InvoiceStatus::PAID->value,
                            'due_date' => $dueDate,
                            'created_at' => $baseDate,
                            'updated_at' => $paidAt,
                        ]
                    );

                    Payment::updateOrCreate(
                        ['invoice_id' => $invoice->id],
                        [
                            'payment_method' => $method,
                            'transaction_id' => $this->transactionId($method, $invoice->id),
                            'payment_proof_path' => $method === 'manual' ? 'proofs/bukti_transfer_sample.jpg' : null,
                            'status' => PaymentStatus::VERIFIED->value,
                            'admin_notes' => null,
                            'created_at' => $paidAt,
                            'updated_at' => $paidAt->copy()->addHours(rand(1, 4)),
                        ]
                    );
                }

                // Bulan ini — distribusi realistis:
                // - 60% LUNAS (verified)
                // - 20% PENDING verifikasi (upload bukti, tunggu admin)
                // - 20% BELUM BAYAR / OVERDUE (tidak ada payment sama sekali)
                $roll = $schedule->id % 5; // deterministik berdasar ID
                $invoiceDate = $now->copy()->startOfMonth()->addDays(rand(1, 3));
                $dueDate = $invoiceDate->copy()->addDays(10);

                $isOverdue = $dueDate->isPast();

                $invoiceStatus = match (true) {
                    $roll < 3 => InvoiceStatus::PAID->value,   // 60%
                    $roll === 3 => InvoiceStatus::UNPAID->value, // 20% – pending payment
                    default => InvoiceStatus::UNPAID->value, // 20% – belum bayar
                };

                $invoiceNumber = $this->invoiceNumber($invoiceDate, $invoiceSeq++);
                $invoice = Invoice::updateOrCreate(
                    ['invoice_number' => $invoiceNumber],
                    [
                        'schedule_id' => $schedule->id,
                        'amount' => $amount,
                        'status' => $invoiceStatus,
                        'due_date' => $dueDate,
                        'created_at' => $invoiceDate,
                        'updated_at' => $invoiceDate,
                    ]
                );

                if ($roll < 3) {
                    // LUNAS
                    $paidAt = $invoiceDate->copy()->addDays(rand(1, 8));
                    $method = $this->randomMethod();

                    Payment::updateOrCreate(
                        ['invoice_id' => $invoice->id],
                        [
                            'payment_method' => $method,
                            'transaction_id' => $this->transactionId($method, $invoice->id),
                            'payment_proof_path' => $method === 'manual' ? 'proofs/bukti_transfer_sample.jpg' : null,
                            'status' => PaymentStatus::VERIFIED->value,
                            'created_at' => $paidAt,
                            'updated_at' => $paidAt->copy()->addHours(2),
                        ]
                    );

                } elseif ($roll === 3) {
                    // PENDING – sudah upload bukti, belum diverifikasi admin
                    $uploadedAt = $now->copy()->subDays(rand(0, 2));

                    Payment::updateOrCreate(
                        ['invoice_id' => $invoice->id],
                        [
                            'payment_method' => 'manual',
                            'payment_proof_path' => 'proofs/bukti_transfer_pending.jpg',
                            'transaction_id' => null,
                            'status' => PaymentStatus::PENDING->value,
                            'admin_notes' => null,
                            'created_at' => $uploadedAt,
                            'updated_at' => $uploadedAt,
                        ]
                    );
                }
                // $roll === 4: tidak ada payment – overdue jika sudah lewat jatuh tempo

                // ── B. SCHEDULE PENDING: satu invoice awal, sebagian sudah upload ──
            } elseif ($schedule->status->value === 'pending') {
                $dueDate = $now->copy()->addDays(rand(3, 10));

                $invoiceNumber = $this->invoiceNumber($now, $invoiceSeq++);
                $invoice = Invoice::updateOrCreate(
                    ['invoice_number' => $invoiceNumber],
                    [
                        'schedule_id' => $schedule->id,
                        'amount' => $amount,
                        'status' => InvoiceStatus::UNPAID->value,
                        'due_date' => $dueDate,
                        'created_at' => $now->copy()->subDays(rand(1, 3)),
                        'updated_at' => $now,
                    ]
                );

                // Separuh schedule pending sudah upload bukti bayar
                if ($schedule->id % 2 === 0) {
                    Payment::updateOrCreate(
                        ['invoice_id' => $invoice->id],
                        [
                            'payment_method' => 'manual',
                            'payment_proof_path' => 'proofs/bukti_transfer_pending.jpg',
                            'status' => PaymentStatus::PENDING->value,
                            'created_at' => $now->copy()->subHours(rand(1, 12)),
                            'updated_at' => $now,
                        ]
                    );
                }
            }
        }

        // ── C. Tambah 1 contoh payment REJECTED (realistis untuk history) ──
        $firstUnpaidInvoice = Invoice::where('status', InvoiceStatus::UNPAID->value)->first();
        if ($firstUnpaidInvoice) {
            $rejectedAt = $now->copy()->subDays(3);
            Payment::firstOrCreate(
                [
                    'invoice_id' => $firstUnpaidInvoice->id,
                    'status' => PaymentStatus::REJECTED->value,
                ],
                [
                    'payment_method' => 'manual',
                    'payment_proof_path' => 'proofs/bukti_blur.jpg',
                    'admin_notes' => 'The transfer proof is unreadable or blurry. Please upload a clearer proof.',
                    'created_at' => $rejectedAt,
                    'updated_at' => $rejectedAt->copy()->addHours(1),
                ]
            );
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PENGELUARAN OPERASIONAL
    // ─────────────────────────────────────────────────────────────────────────

    private function seedExpenses(): void
    {
        $now = Carbon::now();

        /**
         * Data pengeluaran realistis untuk wisma / kos:
         * Kategori: Utilitas, Perawatan, Kebersihan, Administrasi, Perlengkapan
         */
        $expenseTemplates = [
            // ── UTILITAS ──────────────────────────────────────────────────
            ['title' => 'PLN Electricity Bill', 'min' => 850_000,  'max' => 1_200_000, 'freq' => 'monthly', 'desc' => 'Payment of the PLN electricity bill for the entire boarding house area.'],
            ['title' => 'PDAM Water Bill',    'min' => 180_000,  'max' => 320_000,   'freq' => 'monthly', 'desc' => 'Payment of the PDAM water bill for the current month.'],
            ['title' => 'IndiHome Internet Cost', 'min' => 350_000, 'max' => 350_000, 'freq' => 'monthly', 'desc' => 'Subscription to the 50 Mbps IndiHome internet for common facilities.'],

            // ── PERAWATAN & PERBAIKAN ──────────────────────────────────────
            ['title' => 'Room AC Servicing',          'min' => 150_000, 'max' => 350_000, 'freq' => 'occasional', 'desc' => 'Servicing and freon refilling of the AC units in several rooms.'],
            ['title' => 'Leaking Faucet Repair',     'min' => 75_000,  'max' => 200_000, 'freq' => 'occasional', 'desc' => 'Repairman fees and materials for fixing a leaking faucet in the bathroom.'],
            ['title' => 'Lamp and Fitting Replacement', 'min' => 50_000, 'max' => 150_000, 'freq' => 'occasional', 'desc' => 'Purchase of LED lamps and fittings to replace the broken ones.'],
            ['title' => 'Room Door Lock Repair', 'min' => 80_000, 'max' => 180_000, 'freq' => 'occasional', 'desc' => 'Locksmith fees for repairing or replacing door locks.'],
            ['title' => 'Wall Painting & Materials',     'min' => 300_000, 'max' => 800_000, 'freq' => 'rare', 'desc' => 'Repainting the room walls or corridor areas that have started to fade.'],

            // ── KEBERSIHAN ─────────────────────────────────────────────────
            ['title' => 'Cleaning Supplies', 'min' => 120_000, 'max' => 250_000, 'freq' => 'bimonthly', 'desc' => 'Purchase of soap, cleaning liquid, brooms, and other cleaning supplies.'],
            ['title' => 'Cleaning Staff Wages',  'min' => 400_000, 'max' => 600_000, 'freq' => 'monthly',  'desc' => 'Daily honorarium for the cleaning staff in charge of the common areas.'],
            ['title' => 'Room & Bathroom Air Freshener', 'min' => 50_000, 'max' => 120_000, 'freq' => 'bimonthly', 'desc' => 'Air fresheners for the rooms and bathrooms for resident comfort.'],

            // ── PERLENGKAPAN & INVENTARIS ──────────────────────────────────
            ['title' => 'Pillow & Bolster Purchase', 'min' => 200_000, 'max' => 500_000, 'freq' => 'rare', 'desc' => 'Replacement of the pillows and bolsters that are no longer fit for use.'],
            ['title' => 'Additional Bathroom Towel Rack', 'min' => 90_000, 'max' => 220_000, 'freq' => 'rare', 'desc' => 'Installation of new towel racks in several bathrooms.'],
            ['title' => 'Shared Laundry Detergent Purchase', 'min' => 35_000,  'max' => 80_000,  'freq' => 'bimonthly', 'desc' => 'Detergent for the shared laundry area.'],

            // ── ADMINISTRASI & LAIN-LAIN ───────────────────────────────────
            ['title' => 'Office Supplies & Administration Cost', 'min' => 30_000,  'max' => 100_000, 'freq' => 'monthly',   'desc' => 'Purchase of office stationery and administrative needs.'],
            ['title' => 'Snacks & Meeting Refreshments',   'min' => 80_000,  'max' => 200_000, 'freq' => 'occasional', 'desc' => 'Refreshments for the monthly boarding house management meeting.'],
            ['title' => 'Parking & Transportation Cost', 'min' => 20_000, 'max' => 75_000, 'freq' => 'monthly', 'desc' => 'Transportation costs for the boarding house operations.'],
            ['title' => 'Neighborhood Security Fee', 'min' => 100_000, 'max' => 100_000, 'freq' => 'monthly', 'desc' => 'Residents security dues for the security of the boarding house area.'],
        ];

        $expenseSeq = 1;

        for ($monthsAgo = 5; $monthsAgo >= 0; $monthsAgo--) {
            $targetMonth = Carbon::now()->subMonths($monthsAgo);

            foreach ($expenseTemplates as $tmpl) {
                // Tentukan apakah expense ini muncul di bulan ini
                $shouldCreate = match ($tmpl['freq']) {
                    'monthly' => true,
                    'bimonthly' => ($monthsAgo % 2 === 0),
                    'occasional' => (rand(0, 2) > 0),  // ~67%
                    'rare' => (rand(0, 4) === 0), // ~20%
                    default => false,
                };

                if (! $shouldCreate) {
                    continue;
                }

                $amount = rand((int) ($tmpl['min'] / 1000), (int) ($tmpl['max'] / 1000)) * 1000;
                $expenseDate = $targetMonth->copy()->startOfMonth()->addDays(rand(1, 25));

                // Jangan over-shoot ke masa depan
                if ($expenseDate->isFuture()) {
                    $expenseDate = Carbon::now()->subDays(rand(0, 3));
                }

                Expense::updateOrCreate(
                    [
                        'title' => $tmpl['title'],
                        'expense_date' => $expenseDate->toDateString(),
                    ],
                    [
                        'description' => $tmpl['desc'],
                        'amount' => $amount,
                        'reference_id' => null,
                        'reference_type' => null,
                        'created_at' => $expenseDate,
                        'updated_at' => $expenseDate,
                    ]
                );

                $expenseSeq++;
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // HELPER METHODS
    // ─────────────────────────────────────────────────────────────────────────

    private function invoiceNumber(Carbon $date, int $seq): string
    {
        return 'INV-'.$date->format('Ym').'-'.str_pad($seq, 4, '0', STR_PAD_LEFT);
    }

    private function randomMethod(): string
    {
        // 70% manual transfer, 30% midtrans/QRIS
        return rand(1, 10) <= 7 ? 'manual' : 'midtrans';
    }

    private function transactionId(string $method, int $invoiceId): ?string
    {
        if ($method === 'midtrans') {
            return 'TXN-MID-'.strtoupper(substr(md5($invoiceId.microtime()), 0, 12));
        }

        return 'TXN-TF-'.strtoupper(substr(md5($invoiceId.rand()), 0, 10));
    }
}
