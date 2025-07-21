<?php

namespace App\Filament\Resources\UserResource\Pages;

use App\Filament\Resources\UserResource;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Facades\Hash;
use Illuminate\Database\Eloquent\Model;

class CreateUser extends CreateRecord
{
    protected static string $resource = UserResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        if (isset($data['password']) && $data['password']) {
            $data['password'] = Hash::make($data['password']);
        }

        return $data;
    }

    protected function handleRecordCreation(array $data): Model
    {
        // Menambahkan verifikasi email otomatis jika tidak diisi
        if (!isset($data['email_verified_at']) || !$data['email_verified_at']) {
            $data['email_verified_at'] = now();
        }
        
        return static::getModel()::create($data);
    }
}
