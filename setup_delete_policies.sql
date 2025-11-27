-- ============================================
-- SUPABASE DELETE POLICIES CHO MESSAGES VÀ CONVERSATIONS
-- ============================================
-- Copy toàn bộ file này và paste vào Supabase SQL Editor
-- Sau đó click "Run" để tạo tất cả policies

-- ============================================
-- POLICIES CHO BẢNG MESSAGES
-- ============================================

-- Policy 1: Cho phép user xóa tin nhắn của chính mình
DROP POLICY IF EXISTS "Users can delete their own messages" ON messages;
CREATE POLICY "Users can delete their own messages"
ON messages FOR DELETE
TO authenticated
USING (auth.uid() = sender_id);

-- Policy 2: Cho phép user xóa tất cả messages trong conversation của họ
-- (Nếu muốn cho phép xóa cả conversation và tất cả messages)
DROP POLICY IF EXISTS "Users can delete messages in their conversations" ON messages;
CREATE POLICY "Users can delete messages in their conversations"
ON messages FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM conversations
    WHERE conversations.id = messages.conversation_id
    AND (conversations.user1_id = auth.uid() OR conversations.user2_id = auth.uid())
  )
);

-- ============================================
-- POLICIES CHO BẢNG CONVERSATIONS
-- ============================================

-- Policy: Cho phép user xóa conversation mà họ tham gia
DROP POLICY IF EXISTS "Users can delete their conversations" ON conversations;
CREATE POLICY "Users can delete their conversations"
ON conversations FOR DELETE
TO authenticated
USING (
  user1_id = auth.uid() OR user2_id = auth.uid()
);

