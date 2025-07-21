<?php

namespace App\Filament\Resources\PengaduanResource\Pages;

use App\Filament\Resources\PengaduanResource;
use Filament\Resources\Pages\ViewRecord;
use Filament\Infolists\Infolist;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\Section;
use Filament\Infolists\Components\Grid;

class ViewPengaduan extends ViewRecord
{
    protected static string $resource = PengaduanResource::class;
    
    public function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Section::make('Informasi Pengaduan')
                    ->schema([
                        Grid::make(3)
                            ->schema([
                                TextEntry::make('nomor_pengaduan')
                                    ->label('Nomor Pengaduan'),
                                TextEntry::make('user.name')
                                    ->label('Pelapor'),
                                TextEntry::make('kategori.nama')
                                    ->label('Kategori'),
                            ]),
                        Grid::make(2)
                            ->schema([
                                TextEntry::make('judul')
                                    ->label('Judul Pengaduan'),
                                TextEntry::make('lokasi')
                                    ->label('Lokasi'),
                            ]),
                        TextEntry::make('deskripsi')
                            ->label('Deskripsi')
                            ->columnSpanFull(),
                        ImageEntry::make('foto')
                            ->label('Bukti Foto')
                            ->disk('public')
                            ->height(300)
                            ->columnSpanFull(),
                    ]),
                    
                Section::make('Status dan Tanggapan')
                    ->schema([
                        Grid::make(3)
                            ->schema([
                                TextEntry::make('status')
                                    ->badge()
                                    ->label('Status')
                                    ->colors([
                                        'warning' => fn ($state) => $state === 'pending',
                                        'primary' => fn ($state) => $state === 'diproses',
                                        'success' => fn ($state) => $state === 'selesai',
                                        'danger' => fn ($state) => $state === 'ditolak',
                                    ]),
                                TextEntry::make('admin.name')
                                    ->label('Admin Penanggap')
                                    ->placeholder('Belum ditanggapi'),
                                TextEntry::make('tanggal_selesai')
                                    ->label('Tanggal Selesai')
                                    ->dateTime()
                                    ->placeholder('Belum selesai'),
                            ]),
                        TextEntry::make('tanggapan')
                            ->label('Tanggapan Admin')
                            ->columnSpanFull()
                            ->placeholder('Belum ada tanggapan'),
                        ImageEntry::make('foto_tanggapan')
                            ->label('Bukti Foto Tanggapan')
                            ->disk('public')
                            ->height(300)
                            ->visible(fn ($record) => $record->foto_tanggapan)
                            ->columnSpanFull(),
                    ]),
                    
                Section::make('Penilaian Pengguna')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                TextEntry::make('rating')
                                    ->label('Rating')
                                    ->placeholder('Belum diberi rating')
                                    ->formatStateUsing(fn ($state) => $state ? "⭐ {$state}/5" : null),
                                TextEntry::make('feedback')
                                    ->label('Feedback')
                                    ->placeholder('Belum ada feedback'),
                            ]),
                    ])
                    ->visible(fn ($record) => $record->status === 'selesai'),
            ]);
    }
}
