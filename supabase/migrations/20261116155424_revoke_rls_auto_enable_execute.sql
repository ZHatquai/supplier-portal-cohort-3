-- revoke_rls_auto_enable_execute: the platform's auto-enable-RLS event trigger function stays,
-- but no API role may call it directly (hard rule: no function callable by anon).
revoke execute on function public.rls_auto_enable() from public, anon, authenticated;
