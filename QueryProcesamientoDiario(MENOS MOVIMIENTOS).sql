-- Cargar el XML en SQL Server
DECLARE @XML XML;

BEGIN TRANSACTION;

BEGIN TRY;
	-- Cargar el archivo XML desde la ruta proporcionada
	SELECT @XML = CONVERT(XML, BULKColumn)
	FROM OPENROWSET(BULK 'C:\Users\sguil\OneDrive\Universidad\TEC\Semestre #6\Bases de Datos I\Tercera Tarea\OperacionesCompleto.xml', SINGLE_BLOB) AS X;

	-- Insertar en Usuario
	INSERT INTO dbo.Usuario(Username,Password,IdTipoUsuario)
	SELECT 
		NTH.value('@NombreUsuario', 'VARCHAR(64)'),
		NTH.value('@Password','VARCHAR(64)'),
		2
	FROM @XML.nodes('/root/fechaOperacion/NTH') AS FechaOperacion(FechaOperacion)
	OUTER APPLY FechaOperacion.nodes('NTH') AS N(NTH)

	-- Insertar en TarjetaHabiente
	INSERT INTO dbo.TarjetaHabiente(Nombre, DocumentoIdentidad, IdUsuario, FechaNacimiento)
	SELECT 
		NTH.value('@Nombre', 'VARCHAR(64)'),
		NTH.value('@ValorDocIdentidad','VARCHAR(64)'),
		U.Id,
		NTH.value('@FechaNacimiento','DATE')
	FROM @XML.nodes('/root/fechaOperacion/NTH') AS FechaOperacion(FechaOperacion)
	OUTER APPLY FechaOperacion.nodes('NTH') AS N(NTH)
	JOIN dbo.Usuario U ON U.Username = NTH.value('@NombreUsuario','VARCHAR(64)')

	-- Insertar en TarjetaCreditoMaestra
	INSERT INTO dbo.TarjetaCreditoMaestra(Codigo,IdTipoTCM,LimiteCredito,IdTH)
	SELECT
		NTCM.value('@Codigo', 'INT'),
        TTCM.Id,
        NTCM.value('@LimiteCredito', 'INT'),
        TH.Id
	FROM @XML.nodes('/root/fechaOperacion/NTCM') AS FechaOperacion(FechaOperacion)
	OUTER APPLY FechaOperacion.nodes('NTCM') AS NTC(NTCM)
    JOIN dbo.TarjetaHabiente TH ON TH.DocumentoIdentidad = NTCM.value('@TH','VARCHAR(64)')
    JOIN dbo.TipoTCM TTCM ON TTCM.Nombre = NTCM.value('@TipoTCM','VARCHAR(64)')

	    -- Insertar en TarjetaCreditoAdicional
    INSERT INTO dbo.TarjetaCreditoAdicional(Codigo,IdTCM,IdTH)
    SELECT
        NTCA.value('@CodigoTCA', 'INT'),
        TCM.Id,
        TH.Id
    FROM @XML.nodes('/root/fechaOperacion/NTCA') AS FechaOperacion(FechaOperacion)
    OUTER APPLY FechaOperacion.nodes('NTCA') AS NT(NTCA)
    JOIN dbo.TarjetaHabiente TH ON TH.DocumentoIdentidad = NTCA.value('@TH','VARCHAR(64)')
    JOIN dbo.TarjetaCreditoMaestra TCM ON TCM.Codigo = NTCA.value('@CodigoTCM','INT')

    INSERT INTO dbo.TarjetaFisica(Codigo, CodigoTC, FechaVencimiento, CCV, IdMotivoInvalidacion)
    SELECT
        NTF.value('@Codigo', 'BIGINT'),
        NTF.value('@CodigoTC', 'INT'),
        -- Convert 'M/YYYY' to a valid DATE format (e.g., 'YYYY-MM-01')
        DATEFROMPARTS(
            CAST(SUBSTRING(NTF.value('@FechaVencimiento', 'VARCHAR(7)'), CHARINDEX('/', NTF.value('@FechaVencimiento', 'VARCHAR(7)')) + 1, 4) AS INT),
            CAST(LEFT(NTF.value('@FechaVencimiento', 'VARCHAR(7)'), CHARINDEX('/', NTF.value('@FechaVencimiento', 'VARCHAR(7)')) - 1) AS INT),
            1
        ),
        NTF.value('@CCV', 'INT'),
        NULL
    FROM @XML.nodes('/root/fechaOperacion/NTF') AS FechaOperacion(FechaOperacion)
    OUTER APPLY FechaOperacion.nodes('NTF') AS NT(NTF);

	COMMIT TRANSACTION;
END TRY

BEGIN CATCH
    -- Revertir la transaccion si hay un error
    ROLLBACK TRANSACTION;
    -- Mostrar mensaje de error
    PRINT 'Error en la transaccion: ' + ERROR_MESSAGE();
END CATCH;