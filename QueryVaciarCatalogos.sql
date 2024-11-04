BEGIN TRANSACTION;

BEGIN TRY
    -- Delete from tables in the reverse order of dependency to avoid foreign key conflicts
    
    DELETE FROM dbo.TipoMovimientoMoratorios;
    DELETE FROM dbo.TipoMovimientoIntereses;
    DELETE FROM dbo.Usuario;
    DELETE FROM dbo.TipoMovimientoCorriente;
    DELETE FROM dbo.MotivoInvalidacionTarjeta;
    DELETE FROM dbo.ReglasNegocio;
    DELETE FROM dbo.TipoReglasNegocio;
    DELETE FROM dbo.TipoTCM;

    -- Confirm the transaction if everything is successful
    COMMIT TRANSACTION;
    PRINT 'All data cleared successfully.';
END TRY
BEGIN CATCH
    -- Rollback the transaction if there is an error
    ROLLBACK TRANSACTION;
    PRINT 'Error occurred while clearing data: ' + ERROR_MESSAGE();
END CATCH;
