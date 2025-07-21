<?php

namespace App\Filament\Resources;

use App\Filament\Resources\AdminResource\Pages;
use App\Models\Admin;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Collection;
use App\Models\User;

class AdminResource extends Resource
{
    protected static ?string $model = Admin::class;

    protected static ?string $navigationIcon = 'heroicon-o-shield-check';

    protected static ?string $navigationLabel = 'Administrator';

    protected static ?int $navigationSort = 3;

    // Hanya super admin yang bisa mengakses admin management
    public static function canViewAny(): bool
    {
        $user = auth()->user();
        
        // Periksa apakah pengguna adalah instance dari Admin
        if (!($user instanceof Admin)) {
            return false;
        }
        
        $role = $user->getAttribute('role');
        return $role === 'super_admin';
    }

    protected static ?string $modelLabel = 'Administrator';

    protected static ?string $pluralModelLabel = 'Administrator';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->required()
                    ->maxLength(255)
                    ->label('Nama'),
                Forms\Components\TextInput::make('email')
                    ->email()
                    ->required()
                    ->maxLength(255)
                    ->unique(ignoreRecord: true)
                    ->label('Email'),
                Forms\Components\TextInput::make('password')
                    ->password()
                    ->required(fn (string $context): bool => $context === 'create')
                    ->minLength(8)
                    ->dehydrateStateUsing(fn ($state) => Hash::make($state))
                    ->dehydrated(fn ($state) => filled($state))
                    ->label('Password'),
                Forms\Components\TextInput::make('phone')
                    ->tel()
                    ->maxLength(20)
                    ->label('Telepon'),
                Forms\Components\TextInput::make('jabatan')
                    ->maxLength(255)
                    ->label('Jabatan'),
                Forms\Components\Select::make('role')
                    ->options([
                        'admin' => 'Admin',
                        'super_admin' => 'Super Admin',
                        'staff' => 'Staff',
                    ])
                    ->required()
                    ->default('admin')
                    ->label('Role'),
                Forms\Components\Toggle::make('is_active')
                    ->required()
                    ->default(true)
                    ->label('Aktif'),
                Forms\Components\FileUpload::make('avatar')
                    ->image()
                    ->directory('avatars')
                    ->label('Avatar'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('avatar')
                    ->circular()
                    ->label('Avatar'),
                Tables\Columns\TextColumn::make('name')
                    ->searchable()
                    ->label('Nama'),
                Tables\Columns\TextColumn::make('email')
                    ->searchable()
                    ->label('Email'),
                Tables\Columns\TextColumn::make('phone')
                    ->searchable()
                    ->label('Telepon'),
                Tables\Columns\TextColumn::make('jabatan')
                    ->searchable()
                    ->label('Jabatan'),
                Tables\Columns\TextColumn::make('role')
                    ->badge()
                    ->formatStateUsing(function (?string $state): string {
                        if (is_null($state)) return 'User';
                        return ucfirst($state);
                    })
                    ->color(function (Admin $record) {
                        $role = $record->getAttribute('role') ?? '';
                        if ($role === 'admin') return 'primary';
                        if ($role === 'super_admin') return 'success';
                        if ($role === 'staff') return 'info';
                        return 'gray';
                    })
                    ->label('Role'),
                Tables\Columns\IconColumn::make('is_active')
                    ->boolean()
                    ->label('Status'),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true)
                    ->label('Dibuat'),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('role')
                    ->options([
                        'admin' => 'Admin',
                        'super_admin' => 'Super Admin',
                        'staff' => 'Staff',
                    ])
                    ->label('Role'),
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Status'),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\Action::make('change_role')
                    ->icon('heroicon-o-arrow-path')
                    ->label('Ubah Role')
                    ->form([
                        Forms\Components\Select::make('role')
                            ->options([
                                'admin' => 'Admin',
                                'super_admin' => 'Super Admin',
                                'staff' => 'Staff',
                            ])
                            ->required()
                            ->label('Role Baru'),
                    ])
                    ->action(function (Admin $record, array $data): void {
                        $record->update(['role' => $data['role']]);
                    })
                    ->requiresConfirmation()
                    ->modalHeading('Ubah Role Administrator')
                    ->modalDescription('Apakah Anda yakin ingin mengubah role administrator ini?')
                    ->modalSubmitActionLabel('Ubah Role'),
                Tables\Actions\Action::make('toggle_status')
                    ->icon('heroicon-o-power')
                    ->label(function (Admin $record): string {
                        // Gunakan null coalescing untuk memastikan nilai tidak null
                        $isActive = $record->getAttribute('is_active') ?? false;
                        return $isActive ? 'Nonaktifkan' : 'Aktifkan';
                    })
                    ->color(function (Admin $record): string {
                        $isActive = $record->getAttribute('is_active') ?? false;
                        return $isActive ? 'danger' : 'success';
                    })
                    ->action(function (Admin $record): void {
                        $isActive = $record->getAttribute('is_active') ?? false;
                        $record->update(['is_active' => !$isActive]);
                    })
                    ->requiresConfirmation()
                    ->modalHeading(function (Admin $record): string {
                        $isActive = $record->getAttribute('is_active') ?? false;
                        return $isActive ? 'Nonaktifkan Administrator' : 'Aktifkan Administrator';
                    })
                    ->modalDescription(function (Admin $record): string {
                        $isActive = $record->getAttribute('is_active') ?? false;
                        return $isActive ? 'Administrator akan dinonaktifkan dan tidak bisa login.' : 'Administrator akan diaktifkan dan bisa login kembali.';
                    })
                    ->modalSubmitActionLabel(function (Admin $record): string {
                        $isActive = $record->getAttribute('is_active') ?? false;
                        return $isActive ? 'Nonaktifkan' : 'Aktifkan';
                    }),
                Tables\Actions\Action::make('demote_to_user')
                    ->icon('heroicon-o-arrow-down')
                    ->label('Jadikan User')
                    ->color('warning')
                    ->visible(function (Admin $record): bool {
                        $user = auth()->user();
                        // Pastikan user adalah instance dari Admin
                        if (!$user || !($user instanceof Admin)) {
                            return false;
                        }
                        $userRole = $user->getAttribute('role');
                        $recordRole = $record->getAttribute('role');
                        return $userRole === 'super_admin' && $recordRole !== 'super_admin';
                    })
                    ->form([
                        Forms\Components\TextInput::make('nama_instansi')
                            ->label('Nama Instansi')
                            ->placeholder('Contoh: Dinas Pendidikan')
                            ->required(),
                    ])
                    ->action(function (Admin $record, array $data): void {
                        // Buat record user baru dengan data yang aman
                        $userData = [
                            'name' => $record->getAttribute('name') ?? '',
                            'email' => $record->getAttribute('email') ?? '',
                            // Buat password baru karena password yang sudah di-hash tidak dapat digunakan kembali
                            'password' => Hash::make(\Illuminate\Support\Str::random(10)),
                            'phone' => $record->getAttribute('phone') ?? null,
                            'nama_instansi' => $data['nama_instansi'] ?? 'Warga Gunung Kidul',
                            'is_active' => true,
                        ];
                        
                        User::create($userData);
                        
                        // Hapus admin dari table admins
                        $record->delete();
                    })
                    ->requiresConfirmation()
                    ->modalHeading('Demosi ke User')
                    ->modalDescription('Administrator akan didemosi menjadi user biasa dan dipindahkan ke tabel user.')
                    ->modalSubmitActionLabel('Demosikan'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\BulkAction::make('activate')
                        ->label('Aktifkan')
                        ->icon('heroicon-o-check')
                        ->color('success')
                        ->action(function (Collection $records) {
                            foreach ($records as $record) {
                                if ($record instanceof Admin) {
                                    $record->update(['is_active' => true]);
                                }
                            }
                        })
                        ->requiresConfirmation(),
                    Tables\Actions\BulkAction::make('deactivate')
                        ->label('Nonaktifkan')
                        ->icon('heroicon-o-x-mark')
                        ->color('danger')
                        ->action(function (Collection $records) {
                            foreach ($records as $record) {
                                if ($record instanceof Admin) {
                                    $record->update(['is_active' => false]);
                                }
                            }
                        })
                        ->requiresConfirmation(),
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
            'index' => Pages\ListAdmins::route('/'),
            'create' => Pages\CreateAdmin::route('/create'),
            'view' => Pages\ViewAdmin::route('/{record}'),
            'edit' => Pages\EditAdmin::route('/{record}/edit'),
        ];
    }
}
