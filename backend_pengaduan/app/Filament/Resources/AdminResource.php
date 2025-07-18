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
        return auth()->user()?->role === 'super_admin';
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
                    ->colors([
                        'primary' => 'admin',
                        'success' => 'super_admin',
                    ])
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
                    ->label(fn (Admin $record): string => $record->is_active ? 'Nonaktifkan' : 'Aktifkan')
                    ->color(fn (Admin $record): string => $record->is_active ? 'danger' : 'success')
                    ->action(function (Admin $record): void {
                        $record->update(['is_active' => !$record->is_active]);
                    })
                    ->requiresConfirmation()
                    ->modalHeading(fn (Admin $record): string => $record->is_active ? 'Nonaktifkan Administrator' : 'Aktifkan Administrator')
                    ->modalDescription(fn (Admin $record): string => $record->is_active ? 'Administrator akan dinonaktifkan dan tidak bisa login.' : 'Administrator akan diaktifkan dan bisa login kembali.')
                    ->modalSubmitActionLabel(fn (Admin $record): string => $record->is_active ? 'Nonaktifkan' : 'Aktifkan'),
                Tables\Actions\Action::make('demote_to_user')
                    ->icon('heroicon-o-arrow-down')
                    ->label('Jadikan User')
                    ->color('warning')
                    ->visible(fn (Admin $record): bool => auth()->user()?->role === 'super_admin' && $record->role !== 'super_admin')
                    ->form([
                        Forms\Components\TextInput::make('nama_instansi')
                            ->label('Nama Instansi')
                            ->placeholder('Contoh: Dinas Pendidikan'),
                    ])
                    ->action(function (Admin $record, array $data): void {
                        // Buat record user baru
                        User::create([
                            'name' => $record->name,
                            'email' => $record->email,
                            'password' => $record->password,
                            'phone' => $record->phone,
                            'nama_instansi' => $data['nama_instansi'] ?? 'Warga Gunung Kidul',
                        ]);
                        
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
                        ->action(fn (Collection $records) => $records->each->update(['is_active' => true]))
                        ->requiresConfirmation(),
                    Tables\Actions\BulkAction::make('deactivate')
                        ->label('Nonaktifkan')
                        ->icon('heroicon-o-x-mark')
                        ->color('danger')
                        ->action(fn (Collection $records) => $records->each->update(['is_active' => false]))
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
