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

    // Hanya super admin yang bisa mengakses user management
    public static function canViewAny(): bool
    {
        return auth()->user()?->role === 'super_admin';
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
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true)
                    ->label('Dibuat'),
            ])
            ->filters([
                Tables\Filters\Filter::make('verified')
                    ->query(fn (Builder $query): Builder => $query->whereNotNull('email_verified_at'))
                    ->label('Verified Users'),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\Action::make('promote_to_admin')
                    ->icon('heroicon-o-arrow-up')
                    ->label('Jadikan Admin')
                    ->color('success')
                    ->visible(fn (): bool => auth()->user()?->role === 'super_admin')
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
                            'name' => $record->name,
                            'email' => $record->email,
                            'password' => $record->password,
                            'phone' => $record->phone,
                            'jabatan' => $data['jabatan'],
                            'role' => $data['role'],
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
