<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Hash;
use App\Models\Admin;


class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $navigationIcon = 'heroicon-o-users';

    protected static ?string $navigationLabel = 'Pengguna';

    protected static ?string $modelLabel = 'Pengguna';

    protected static ?string $pluralModelLabel = 'Pengguna';

    protected static ?int $navigationSort = 2;

    // Admin, super admin, dan staff bisa mengakses user management
    public static function canViewAny(): bool
    {
        $user = auth()->user();
        $role = $user ? $user->getAttribute('role') : null;
        return $role === 'super_admin' || $role === 'admin' || $role === 'staff';
    }
    
    // Hanya super admin yang bisa menghapus user
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
                Forms\Components\TextInput::make('name')
                    ->required()
                    ->maxLength(255)
                    ->label('Nama'),
                Forms\Components\TextInput::make('email')
                    ->email()
                    ->required()
                    ->maxLength(255)
                    ->label('Email'),
                Forms\Components\TextInput::make('phone')
                    ->tel()
                    ->maxLength(20)
                    ->label('Telepon'),
                Forms\Components\TextInput::make('nama_instansi')
                    ->maxLength(255)
                    ->label('Nama Instansi'),
                Forms\Components\TextInput::make('password')
                    ->password()
                    ->dehydrateStateUsing(fn (string $state): string => Hash::make($state))
                    ->required(fn ($livewire) => $livewire instanceof Pages\CreateUser)
                    ->maxLength(255)
                    ->label('Password')
                    ->hiddenOn('view'),
                Forms\Components\TextInput::make('password_confirmation')
                    ->password()
                    ->required(fn ($livewire) => $livewire instanceof Pages\CreateUser)
                    ->maxLength(255)
                    ->dehydrated(false)
                    ->label('Konfirmasi Password')
                    ->hiddenOn(['view', 'edit']),
                Forms\Components\Toggle::make('is_active')
                    ->label('Aktif')
                    ->default(true),
                Forms\Components\DateTimePicker::make('email_verified_at')
                    ->label('Email Verified At'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->searchable()
                    ->label('Nama'),
                Tables\Columns\TextColumn::make('email')
                    ->searchable()
                    ->label('Email'),
                Tables\Columns\TextColumn::make('phone')
                    ->searchable()
                    ->label('Telepon'),
                Tables\Columns\TextColumn::make('nama_instansi')
                    ->searchable()
                    ->label('Nama Instansi'),
                Tables\Columns\TextColumn::make('email_verified_at')
                    ->dateTime()
                    ->sortable()
                    ->label('Email Verified'),
                Tables\Columns\IconColumn::make('is_active')
                    ->boolean()
                    ->label('Status Aktif')
                    ->trueIcon('heroicon-o-check-circle')
                    ->falseIcon('heroicon-o-x-circle')
                    ->trueColor('success')
                    ->falseColor('danger'),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true)
                    ->label('Dibuat'),
            ])
            ->filters([
                Tables\Filters\Filter::make('verified')
                    ->query(fn (Builder $query) => $query->whereNotNull('email_verified_at'))
                    ->label('Verified Users'),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\Action::make('toggle_active')
                    ->icon(function (User $record): string {
                        $isActive = $record->getAttribute('is_active') ?? false;
                        return $isActive ? 'heroicon-o-x-circle' : 'heroicon-o-check-circle';
                    })
                    ->label(function (User $record): string {
                        $isActive = $record->getAttribute('is_active') ?? false;
                        return $isActive ? 'Nonaktifkan' : 'Aktifkan';
                    })
                    ->color(function (User $record): string {
                        $isActive = $record->getAttribute('is_active') ?? false;
                        return $isActive ? 'danger' : 'success';
                    })
                    ->requiresConfirmation()
                    ->modalHeading(function (User $record): string {
                        $isActive = $record->getAttribute('is_active') ?? false;
                        return $isActive ? 'Nonaktifkan Pengguna' : 'Aktifkan Pengguna';
                    })
                    ->modalDescription(function (User $record): string {
                        $isActive = $record->getAttribute('is_active') ?? false;
                        return $isActive ? 'Apakah Anda yakin ingin menonaktifkan pengguna ini?' : 'Apakah Anda yakin ingin mengaktifkan pengguna ini?';
                    })
                    ->action(function (User $record): void {
                        $isActive = $record->getAttribute('is_active') ?? false;
                        $record->update(['is_active' => !$isActive]);
                    }),
                Tables\Actions\Action::make('promote_to_admin')
                    ->icon('heroicon-o-arrow-up')
                    ->label('Jadikan Admin')
                    ->color('success')
                    ->visible(function (): bool {
                        $user = auth()->user();
                        $role = $user ? $user->getAttribute('role') : null;
                        return $role === 'super_admin';
                    })
                    ->form([
                        Forms\Components\TextInput::make('jabatan')
                            ->required()
                            ->label('Jabatan'),
                        Forms\Components\Select::make('role')
                            ->options([
                                'admin' => 'Admin',
                                'super_admin' => 'Super Admin',
                            ])
                            ->default('admin')
                            ->required()
                            ->label('Role Admin'),
                    ])
                    ->action(function (User $record, array $data): void {
                        // Buat record admin baru
                        Admin::create([
                            'name' => $record->getAttribute('name') ?? '',
                            'email' => $record->getAttribute('email') ?? '',
                            // Buat password baru yang aman
                            'password' => Hash::make(\Illuminate\Support\Str::random(10)),
                            'phone' => $record->getAttribute('phone') ?? null,
                            'jabatan' => $data['jabatan'] ?? '',
                            'role' => $data['role'] ?? 'admin',
                            'is_active' => true,
                        ]);
                        
                        // Hapus user dari table users
                        $record->delete();
                    })
                    ->requiresConfirmation()
                    ->modalHeading('Promosi ke Administrator')
                    ->modalDescription('User akan dipromosikan menjadi administrator dan dipindahkan ke tabel admin.')
                    ->modalSubmitActionLabel('Promosikan'),
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
            'index' => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'view' => Pages\ViewUser::route('/{record}'),
            'edit' => Pages\EditUser::route('/{record}/edit'),
        ];
    }
}
