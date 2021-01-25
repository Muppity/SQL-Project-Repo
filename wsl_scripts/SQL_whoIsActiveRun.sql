use master
go
exec sp_whoisactive @show_own_spid  = 1, @show_sleeping_spids  = 2,@get_full_inner_text = 1, @get_transaction_info = 1, @get_task_info = 1
,@get_avg_time  = 1,@get_additional_info = 1