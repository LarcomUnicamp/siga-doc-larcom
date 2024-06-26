package br.gov.jfrj.siga.api.v1;

import br.gov.jfrj.siga.api.v1.ISigaApiV1.IArmazenamentoEstatisticasGet;
import br.gov.jfrj.siga.cp.CpArquivoTipoArmazenamentoEnum;
import br.gov.jfrj.siga.dp.dao.CpDao;
import br.gov.jfrj.siga.dp.dao.CpDao.ResultadoDeEstatisticasParaMigracaoDeArmazenamento;

public class ArmazenamentoEstatisticasGet implements IArmazenamentoEstatisticasGet {

    @Override
    public void run(Request req, Response resp, SigaApiV1Context ctx) throws Exception {
        CpArquivoTipoArmazenamentoEnum origem = CpArquivoTipoArmazenamentoEnum.valueOf(req.origem);
        CpArquivoTipoArmazenamentoEnum destino = CpArquivoTipoArmazenamentoEnum.valueOf(req.destino);
        ResultadoDeEstatisticasParaMigracaoDeArmazenamento r = CpDao.getInstance()
                .estatisticasParaMigracaoDeArmazenamento(origem, destino);
        if (r != null) {
            resp.quantidade = (double) r.quantidade;
            resp.memoria = (double) r.memoria;
        } else {
            resp.quantidade = 0d;
            resp.memoria = 0d;
        }
    }

    @Override
    public String getContext() {
        return "obter estatísticas de migração de armazenamento";
    }

}
