-- criacao campos ref. sicop
-- connect siga@srv000764.infra.rio.gov.br:1521/sigadoc.pcrj;
ALTER TABLE SIGA.EX_MODELO ADD (IS_SICOP NUMBER DEFAULT 0);
ALTER TABLE SIGA.EX_CLASSIFICACAO ADD (ASSUNTO_SICOP VARCHAR2(20));
COMMIT;