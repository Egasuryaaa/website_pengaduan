<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PengaduanResource\Pages;
use App\Models\Pengaduan;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class PengaduanResource extends Resource
{
    protected static ?string $model = Pengaduan::class;

    protected static ?string $navigationIcon = 'heroicon-o-chat-bubble-left-right';

    protected static ?string $navigationLabel = 'Pengaduan';

    protected static ?string $modelLabel = 'Pengaduan';

    protected static ?string $pluralModelLabel = 'Pengaduan';

    protected static ?int $navigationSort = 1;

    // Semua admin bisa lihat pengaduan
    public static function canViewAny(): bool
    {
        return auth()->check();
    }

    // Hanya super admin yang bisa hapus pengaduan
    public static function canDelete(\Illuminate\Database\Eloquent\Model $record): bool
    {
        $user = auth()->user();
        $role = $user ? $user->getAttribute('role') : null;
        return $role === 'super_admin';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('nomor_pengaduan')
                    ->required()
                    ->maxLength(255)
                    ->disabled()
                    ->label('Nomor Pengaduan'),
                Forms\Components\Select::make('user_id')
                    ->relationship('user', 'name')
                    ->required()
                    ->label('Pengguna'),
                Forms\Components\Select::make('kategori_id')
                    ->relationship('kategori', 'nama')
                    ->required()
                    ->label('Kategori'),
                Forms\Components\TextInput::make('judul')
                    ->required()
                    ->maxLength(255)
                    ->label('Judul'),
                Forms\Components\Textarea::make('deskripsi')
                    ->required()
                    ->columnSpanFull()
                    ->label('Deskripsi'),
                Forms\Components\TextInput::make('lokasi')
                    ->required()
                    ->maxLength(255)
                    ->label('Lokasi'),
                Forms\Components\FileUpload::make('foto')
                    ->image()
                    ->disk('public')
                    ->directory('pengaduan')
                    ->visibility('public')
                    ->downloadable()
                    ->openable()
                    ->label('Bukti Foto')
                    ->columnSpanFull(),
                Forms\Components\Select::make('status')
                    ->options([
                        'pending' => 'Pending',
                        'diproses' => 'Diproses',
                        'selesai' => 'Selesai',
                        'ditolak' => 'Ditolak',
                    ])
                    ->default('pending')
                    ->required()
                    ->label('Status'),
                Forms\Components\Textarea::make('tanggapan')
                    ->columnSpanFull()
                    ->label('Tanggapan'),
                Forms\Components\FileUpload::make('foto_tanggapan')
                    ->image()
                    ->disk('public')
                    ->directory('tanggapan')
                    ->visibility('public')
                    ->downloadable()
                    ->openable()
                    ->label('Bukti Foto Tanggapan')
                    ->columnSpanFull(),
                Forms\Components\Select::make('admin_id')
                    ->relationship('admin', 'name')
                    ->label('Admin'),
                Forms\Components\DateTimePicker::make('tanggal_selesai')
                    ->label('Tanggal Selesai'),
                Forms\Components\TextInput::make('rating')
                    ->numeric()
                    ->minValue(1)
                    ->maxValue(5)
                    ->label('Rating'),
                Forms\Components\Textarea::make('feedback')
                    ->columnSpanFull()
                    ->label('Feedback'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->modifyQueryUsing(function (Builder $query) {
                return $query->with(['user', 'kategori', 'admin']);
            })
            ->columns([
                Tables\Columns\TextColumn::make('nomor_pengaduan')
                    ->searchable()
                    ->label('Nomor'),
                Tables\Columns\TextColumn::make('user.name')
                    ->sortable()
                    ->label('Pengguna'),
                Tables\Columns\TextColumn::make('kategori.nama')
                    ->sortable()
                    ->label('Kategori'),
                Tables\Columns\TextColumn::make('judul')
                    ->searchable()
                    ->limit(50)
                    ->label('Judul'),
                Tables\Columns\TextColumn::make('lokasi')
                    ->searchable()
                    ->limit(30)
                    ->label('Lokasi'),
                Tables\Columns\ImageColumn::make('foto')
                    ->disk('public')
                    ->height(60)
                    ->circular(false)
                    ->defaultImageUrl(url('/images/no-image.png'))
                    ->label('Bukti Foto')
                    ->toggleable(),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->colors([
                        'warning' => 'pending',
                        'primary' => 'diproses',
                        'success' => 'selesai',
                        'danger' => 'ditolak',
                    ])
                    ->label('Status'),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true)
                    ->label('Dibuat'),
                Tables\Columns\TextColumn::make('updated_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true)
                    ->label('Diupdate'),
            ])
            ->defaultSort('created_at', 'desc')
            ->defaultPaginationPageOption(25)
            ->persistSortInSession()
            ->persistSearchInSession()
            ->persistFiltersInSession()
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'pending' => 'Pending',
                        'diproses' => 'Diproses',
                        'selesai' => 'Selesai',
                        'ditolak' => 'Ditolak',
                    ])
                    ->label('Status'),
                Tables\Filters\SelectFilter::make('kategori')
                    ->relationship('kategori', 'nama')
                    ->label('Kategori'),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\Action::make('lihat_foto')
                    ->label('Lihat Foto')
                    ->icon('heroicon-o-photo')
                    ->color('info')
                    ->visible(function ($record) {
                        return $record->getAttribute('foto') !== null;
                    })
                    ->url(function ($record) {
                        $foto = $record->getAttribute('foto');
                        return $foto ? asset('storage/' . $foto) : null;
                    })
                    ->openUrlInNewTab(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListPengaduans::route('/'),
            'create' => Pages\CreatePengaduan::route('/create'),
            'view' => Pages\ViewPengaduan::route('/{record}'),
            'edit' => Pages\EditPengaduan::route('/{record}/edit'),
        ];
    }
}
