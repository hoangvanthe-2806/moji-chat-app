-- ============================================
-- SUPABASE STORAGE POLICIES CHO AVATAR UPLOAD
-- ============================================
-- Copy toàn bộ file này và paste vào Supabase SQL Editor
-- Sau đó click "Run" để tạo tất cả policies

-- Policy 1: Cho phép authenticated users UPLOAD ảnh
-- (BẮT BUỘC - Nếu không có policy này sẽ bị lỗi 403)
DROP POLICY IF EXISTS "Users can upload avatars" ON storage.objects;
CREATE POLICY "Users can upload avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'avatars');

-- Policy 2: Cho phép PUBLIC đọc ảnh (nếu bucket là public)
DROP POLICY IF EXISTS "Public can read avatars" ON storage.objects;
CREATE POLICY "Public can read avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- Policy 3: Cho phép authenticated users UPDATE ảnh
DROP POLICY IF EXISTS "Users can update avatars" ON storage.objects;
CREATE POLICY "Users can update avatars"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'avatars')
WITH CHECK (bucket_id = 'avatars');

-- Policy 4: Cho phép authenticated users DELETE ảnh
DROP POLICY IF EXISTS "Users can delete avatars" ON storage.objects;
CREATE POLICY "Users can delete avatars"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'avatars');

-- ============================================
-- KIỂM TRA BẢNG USERS CÓ POLICY UPDATE CHƯA
-- ============================================
-- Nếu chưa có, chạy câu lệnh sau:

-- DROP POLICY IF EXISTS "Users can update their own profile" ON users;
-- CREATE POLICY "Users can update their own profile"
-- ON users FOR UPDATE
-- TO authenticated
-- USING (auth.uid() = id)
-- WITH CHECK (auth.uid() = id);

