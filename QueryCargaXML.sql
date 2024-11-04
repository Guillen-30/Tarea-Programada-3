-- Cargar el XML en SQL Server
DECLARE @XML XML;

BEGIN TRANSACTION;

BEGIN TRY;
	-- Cargar el archivo XML desde la ruta proporcionada
	SELECT @XML = CONVERT(XML, BULKColumn)
	FROM OPENROWSET(BULK 'C:\Users\sguil\OneDrive\Universidad\TEC\Semestre #6\Bases de Datos I\Tercera Tarea\Catalogos.xml', SINGLE_BLOB) AS X;

	-- Insertar en TipoTCM
	INSERT INTO dbo.TipoTCM(Nombre)
	SELECT T.value('@Nombre', 'VARCHAR(50)')
	FROM @XML.nodes('/root/TTCM/TTCM') AS X(T);

	-- Insertar en TipoReglasNegocio
	INSERT INTO dbo.TipoReglasNegocio(Nombre, Tipo)
	SELECT T.value('@Nombre', 'VARCHAR(50)'),
		   T.value('@tipo', 'VARCHAR(50)')
	FROM @XML.nodes('/root/TRN/TRN') AS X(T);

	-- Insertar en ReglasNegocio
	INSERT INTO dbo.ReglasNegocio(Nombre, IdTipoTCM, IdTipoRN, Valor)
	SELECT 
		T.value('@Nombre', 'VARCHAR(100)'),
		TTCM.Id,
		TRN.Id,
		T.value('@Valor', 'INT')
	FROM @XML.nodes('/root/RN/RN') AS X(T)
	JOIN dbo.TipoTCM TTCM ON TTCM.Nombre = T.value('@TTCM', 'VARCHAR(50)')
	JOIN dbo.TipoReglasNegocio TRN ON TRN.Nombre = T.value('@TipoRN','VARCHAR(50)');

	-- Insertar en MotivoInvalidacionTarjeta
	INSERT INTO dbo.MotivoInvalidacionTarjeta(Nombre)
	SELECT T.value('@Nombre', 'VARCHAR(50)')
	FROM @XML.nodes('/root/MIT/MIT') AS X(T);

	-- Insertar en TipoMovimientoCorriente
	INSERT INTO dbo.TipoMovimientoCorriente(Nombre, Accion, AcumulaOperacionATM, AcumulaOperacionVentana)
	SELECT T.value('@Nombre', 'VARCHAR(100)'),
		   T.value('@Accion', 'VARCHAR(50)'),
		   CASE T.value('@Acumula_Operacion_ATM', 'VARCHAR(10)')
			   WHEN 'SI' THEN 1
			   ELSE 0
		   END,
		   CASE T.value('@Acumula_Operacion_Ventana', 'VARCHAR(10)')
			   WHEN 'SI' THEN 1
			   ELSE 0
		   END
	FROM @XML.nodes('/root/TM/TM') AS X(T);

	-- Insertar TiposUsuario
	INSERT INTO dbo.TipoUsuario(Rol)
	VALUES('Admin'),('TH')


	-- Insertar en Usuario
	INSERT INTO dbo.Usuario(Username, Password, IdTipoUsuario)
	SELECT T.value('@Nombre', 'VARCHAR(50)'),
		   T.value('@Password', 'VARCHAR(50)'),
		   (1)
	FROM @XML.nodes('/root/UA/Usuario') AS X(T);

	-- Insertar en TipoMovimientoIntereses
	INSERT INTO dbo.TipoMovimientoIntereses(Nombre)
	SELECT T.value('@nombre', 'VARCHAR(100)')
	FROM @XML.nodes('/root/TMIC/TMIC') AS X(T);

	-- Insertar en TMIM
	INSERT INTO dbo.TipoMovimientoMoratorios(Nombre)
	SELECT T.value('@nombre', 'VARCHAR(100)')
	FROM @XML.nodes('/root/TMIM/TMIM') AS X(T);

	COMMIT TRANSACTION;
END TRY

BEGIN CATCH
    -- Revertir la transacción si hay un error
    ROLLBACK TRANSACTION;
    -- Mostrar mensaje de error
    PRINT 'Error en la transacción: ' + ERROR_MESSAGE();
END CATCH;