--- Failover From 01 to 02 with data loss.
---By alowing  RPO > 0
:Connect read-scale-01

ALTER AVAILABILITY GROUP [ag_rs] SET (ROLE = SECONDARY);

GO

:Connect read-scale-02

ALTER AVAILABILITY GROUP [ag_rs] FORCE_FAILOVER_ALLOW_DATA_LOSS;

GO


GO
