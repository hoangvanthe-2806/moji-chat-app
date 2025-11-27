# Hướng dẫn cấu hình Supabase Storage cho Avatar

## Bước 1: Tạo Storage Bucket

1. Vào **Supabase Dashboard** → **Storage**
2. Click **"New bucket"** hoặc **"Create bucket"**
3. Đặt tên bucket: `avatars`
4. Chọn **Public bucket** (hoặc Private nếu muốn, nhưng cần cấu hình RLS)
5. Click **"Create bucket"**

## Bước 2: Cấu hình RLS Policy cho Storage

**QUAN TRỌNG**: Sau khi tạo bucket, bạn PHẢI tạo RLS policies, nếu không sẽ gặp lỗi 403 Unauthorized!

Vào **Supabase Dashboard** → **SQL Editor** và chạy các câu lệnh sau:

### Policy 1: Cho phép authenticated users upload ảnh (BẮT BUỘC)

```sql
CREATE POLICY "Users can upload avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'avatars');
```

**Lưu ý**: Nếu policy đã tồn tại, bạn có thể xóa và tạo lại:
```sql
DROP POLICY IF EXISTS "Users can upload avatars" ON storage.objects;
CREATE POLICY "Users can upload avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'avatars');
```

### Policy 2: Cho phép public đọc ảnh (nếu bucket là public)

```sql
CREATE POLICY "Public can read avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');
```

### Policy 3: Cho phép users update ảnh của chính họ

```sql
CREATE POLICY "Authenticated users can update avatars"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'avatars')
WITH CHECK (bucket_id = 'avatars');
```

### Policy 4: Cho phép users xóa ảnh của chính họ

```sql
CREATE POLICY "Authenticated users can delete avatars"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'avatars');
```

## Bước 3: Kiểm tra RLS Policy cho bảng users

Vào **Table Editor** → `users` → **Policies**

Đảm bảo có policy cho phép UPDATE:

```sql
CREATE POLICY "Users can update their own profile"
ON users FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);
```

## Lưu ý:

- Nếu bucket là **Public**: Policy 2 (SELECT) là đủ cho việc đọc
- Nếu bucket là **Private**: Cần policy SELECT cho authenticated users
- File name format: `{userId}.{extension}` (ví dụ: `c109fda6-bf4d-46ee-8d62-e48f1784c612.jpg`)

## Kiểm tra sau khi cấu hình:

1. Upload ảnh lại trong app
2. Kiểm tra Storage → `avatars` bucket có file mới không
3. Kiểm tra bảng `users` → `avatar_url` đã được cập nhật chưa

