DECLARE @FECHA_INICIO AS VARCHAR(8);
DECLARE @FECHA_FIN AS VARCHAR(8);
SET @FECHA_INICIO = '20230101';
SET @FECHA_FIN = '20241231';

	WITH
		Q1 AS (
			      SELECT
				      IdTerceroExterno,
				      SUM(-EfectoSobreElInventario * Cantidad * MontoMonetarioUnitario * ((100 - Dcto) / 100)) * 1000 / 1000 AS MontoPorMesAño,
				      MONTH(Fecha)                                                                                           AS Mes,
				      YEAR(Fecha)                                                                                            AS Año
						  FROM
							  dbo.[CuentasContables - Asientos] CCA
								  INNER JOIN dbo.CCA_M_Inventarios CCAMI
								             ON CCAMI.IdAsientoContable = CCA.IdAsientoContable
								  INNER JOIN dbo.[CuentasContables - Documentos] CCD
								             ON CCD.IdCuentaContableDocumento = CCA.IdCuentaContableDocumento
						 WHERE
							 Fecha BETWEEN @FECHA_INICIO AND @FECHA_FIN
						 GROUP BY
							 IdTerceroExterno,
							 MONTH(Fecha),
							 YEAR(Fecha)
		      )

SELECT
	IdTerceroExterno,
	T.Nombre,
	T.Apellidos,
	Año,
	SUM(IIF(Mes = 1, MontoPorMesAño, 0))  AS ENERO,
	SUM(IIF(Mes = 2, MontoPorMesAño, 0))  AS FEBRERO,
	SUM(IIF(Mes = 3, MontoPorMesAño, 0))  AS MARZO,
	SUM(IIF(Mes = 4, MontoPorMesAño, 0))  AS ABRIL,
	SUM(IIF(Mes = 5, MontoPorMesAño, 0))  AS MAYO,
	SUM(IIF(Mes = 6, MontoPorMesAño, 0))  AS JUNIO,
	SUM(IIF(Mes = 7, MontoPorMesAño, 0))  AS JULIO,
	SUM(IIF(Mes = 8, MontoPorMesAño, 0))  AS AGOSTO,
	SUM(IIF(Mes = 9, MontoPorMesAño, 0))  AS SEPTIEMBRE,
	SUM(IIF(Mes = 10, MontoPorMesAño, 0)) AS OCTUBRE,
	SUM(IIF(Mes = 11, MontoPorMesAño, 0)) AS NOVIEMBRE,
	SUM(IIF(Mes = 12, MontoPorMesAño, 0)) AS DICIEMBRE,
	T.CupoCredito,
	T.Personalizado1                      AS Establecimiento,
	Z.ZonaUno,
	T.Identificacion,
	C.Ciudad,
	D.Departamento
	FROM
		Q1
			INNER JOIN dbo.Terceros T
			           ON T.IdTercero = Q1.IdTerceroExterno
			LEFT JOIN dbo.[Terceros - ZonaUno] Z
			          ON T.IdZonaUno = Z.IdZonaUno
			LEFT JOIN dbo.[Terceros - Direcciones] TD
			          ON T.IdTercero = TD.IdTercero
				          AND TD.senDirecPpal = -1
			LEFT JOIN dbo.Ciudades C
			          ON TD.IdCiudad = C.IdCiudad
			LEFT JOIN dbo.Departamentos D
			          ON C.IdDepartamento = D.IdDepartamento
 WHERE
	 T.Propiedades LIKE '%Cliente%'
 GROUP BY
	 IdTerceroExterno,
	 Nombre,
	 Apellidos,
	 Año,
	 T.CupoCredito,
	 T.Personalizado1,
	 Z.ZonaUno,
	 T.Identificacion,
	 C.Ciudad,
	 D.Departamento
ORDER BY T.Nombre, T.Apellidos, Año
