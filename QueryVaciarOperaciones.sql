BEGIN TRANSACTION;

BEGIN TRY
    -- Delete from tables in the reverse order of dependency to avoid foreign key conflicts
	DELETE FROM dbo.TarjetaFisica
	DELETE FROM dbo.TarjetaCreditoAdicional;
    DELETE FROM dbo.TarjetaCreditoMaestra;
    DELETE FROM dbo.TarjetaHabiente;
    DELETE FROM dbo.Usuario
	WHERE IdTipoUsuario=2

    -- Confirm the transaction if everything is successful
    COMMIT TRANSACTION;
    PRINT 'All data cleared successfully.';
END TRY
BEGIN CATCH
    -- Rollback the transaction if there is an error
    ROLLBACK TRANSACTION;
    PRINT 'Error occurred while clearing data: ' + ERROR_MESSAGE();
END CATCH;
