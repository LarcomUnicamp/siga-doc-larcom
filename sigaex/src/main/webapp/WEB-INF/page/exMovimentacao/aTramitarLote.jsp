<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page contentType="text/html; charset=UTF-8" buffer="64kb" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://localhost/customtag" prefix="tags" %>
<%@ taglib uri="http://localhost/jeetags" prefix="siga" %>
<%@ taglib uri="http://localhost/functiontag" prefix="f" %>

<fmt:message key="documento.transferencia.lote" var="titulo"/>
<siga:pagina titulo="${titulo}">

    <c:set var="thead_color" value="${thead_color}" scope="session"/>

    <div class="container-fluid">
        <div class="card bg-light mb-3">
            <div class="card-header">
                <h5>${titulo}</h5>
            </div>
            <div class="card-body">
                <form name="frm" id="frm" class="form" method="post" action="listar_docs_tramitados" theme="simple">
                    <input type="hidden" name="siglasDocumentosTramitados" value=""/>
                    <input type="hidden" name="errosDocumentosNaoTramitadosJson" value=""/>

                    <div class="row campo-orgao-externo" style="display: none;">
                        <div class="col-sm">
                            <div class="form-group">
                                <span style="color: red"><fmt:message key="tela.tramitar.atencao"/></span>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-3">
                            <div class="form-group">
                                <label for="tipoResponsavel">
                                    <fmt:message key="tela.tramitarLote.tipoResponsavel"/>
                                </label>
                                <select class="custom-select" id="tipoResponsavel" name="tipoResponsavel"
                                        value="${tipoResponsavel}" onchange="updateTipoResponsavel()">
                                    <c:forEach var="item" items="${listaTipoResp}">
                                        <option value="${item.key}" ${item.key == tipoResponsavel ? 'selected' : ''}>
                                                ${item.value}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="form-group">
                                <label>&nbsp;</label>
                                <span id="lotaResponsavel">
									<siga:selecao propriedade="lotaResponsavel" tema="simple"
                                                  modulo="siga" urlAcao="buscar"/>
								</span>
                                <span id="responsavel" style="display: none;">
                                    <siga:selecao propriedade="responsavel" tema="simple"
                                                  modulo="siga" urlAcao="buscar"/>
								</span>
                                <span id="cpOrgao" style="display: none;">
                                    <siga:selecao propriedade="cpOrgao" tema="simple" modulo="siga" urlAcao="buscar"/>
								</span>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-3">
                            <div class="form-group">
                                <label>Data da devolução</label>
                                <input type="text" name="dtDevolucaoMovString"
                                       onblur="verifica_data(this,0,false,false)" value="${dtDevolucaoMovString}"
                                       class="form-control"/>
                                <small class="form-text text-muted">Atenção: somente preencher
                                    a data de devolução se a intenção for, realmente, que o
                                    documento seja devolvido até esta data.</small>
                            </div>
                        </div>
                        <div class="col-sm-3">
                            <div class="form-group campo-orgao-externo" style="display: none;">
                                <div class="form-check form-check-inline mt-4 ">
                                    <input class="form-check-input" type="checkbox" name="protocolo"
                                           id="protocolo" value="mostrar"
                                           <c:if test="${protocolo}">checked</c:if> />
                                    <label class="form-check-label" for="protocolo">
                                        <fmt:message key="tela.tramitar.checkbox"/>
                                    </label>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-3">
                            <div class="form-group campo-orgao-externo" style="display: none;">
                                <label>Observação</label>
                                <input type="text" size="30" name="obsOrgao" id="obsOrgao" class="form-control"/>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-3">
                            <div class="form-group">
                                <button type="button" id="btnOk" class="btn btn-primary" onclick="validar();">
                                    <fmt:message key="documento.transferir"/>
                                </button>
                            </div>
                        </div>
                    </div>
                    <div id="documentos">
                    </div>
                </form>
            </div>
        </div>
        <siga:siga-modal id="confirmacaoModal" exibirRodape="false"
                         tituloADireita="Confirma&ccedil;&atilde;o" linkBotaoDeAcao="#">
            <div class="modal-body">
                Os documentos selecionados ser&atilde;o tramitados para <span id="responsavelSelecionado"></span>.
                Deseja, confirmar?
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-danger" data-dismiss="modal">N&atilde;o</button>
                <a href="#" class="btn btn-success btn-confirmacao" role="button" aria-pressed="true"
                   onclick="confirmar();">
                    Sim</a>
            </div>
        </siga:siga-modal>
        <siga:siga-modal id="progressModal" exibirRodape="false" centralizar="true" tamanhoGrande="true"
                         tituloADireita="Tramitação em lote" linkBotaoDeAcao="#" botaoFecharNoCabecalho="false">
            <div class="modal-body">
                <div id="progressbar-ad"></div>
            </div>
        </siga:siga-modal>
    </div>
    </div>

    <script type="text/javascript">
        window.onload = function () {
            listarDocumentosParaTramitarEmLote();
        }

        function listarDocumentosParaTramitarEmLote(offset) {
            sigaSpinner.mostrar();

            offset = offset == null ? 0 : offset;

            let url = '/sigaex/app/expediente/doc/listar_docs_para_tramitar_lote?offset=' + offset;

            $.ajax({
                url: url,
                success: function (data) {
                    $('#documentos').html(data);
                    sigaSpinner.ocultar();
                },
                error: function (result) {
                    sigaSpinner.ocultar();
                    console.log(result.errormsg);
                },
            });
        }

        function getResponsavelSelecionado() {
            let tipoResponsavelSelecionado = document.getElementById('tipoResponsavel');

            let elementoResponsavelSelecionado = document.getElementById('lotaResponsavel');
            switch (parseInt(tipoResponsavelSelecionado.value)) {
                case 2:
                    elementoResponsavelSelecionado = document.getElementById('responsavel');
                    break;
                case 3:
                    elementoResponsavelSelecionado = document.getElementById('cpOrgao');
                    break;
            }

            return elementoResponsavelSelecionado;
        }

        function getSiglaResponsavelSelecionado() {
            let elementoResponsavelSelecionado = getResponsavelSelecionado();
            let idFormularioResponsavelSelSigla = 'formulario_' + elementoResponsavelSelecionado.id + 'Sel_sigla';
            return document.getElementById(idFormularioResponsavelSelSigla).value;
        }

        function updateTipoResponsavel() {

            limparSelecao();

            let elementoResponsavelSelecionado = getResponsavelSelecionado();
            elementoResponsavelSelecionado.style.display = '';

            if (elementoResponsavelSelecionado.id === 'cpOrgao') {
                Array.from(document.getElementsByClassName('campo-orgao-externo')).forEach(el => el.style.display = '');
            }
        }

        function updateResponsavelSelecionado() {
            document.getElementById('responsavelSelecionado').innerHTML = getSiglaResponsavelSelecionado();
        }

        function limparSelecao() {
            document.getElementById('formulario_lotaResponsavelSel_id').value = "";
            document.getElementById('formulario_lotaResponsavelSel_sigla').value = "";
            document.getElementById('formulario_lotaResponsavelSel_descricao').value = "";
            document.getElementById('lotaResponsavelSelSpan').innerHTML = "";

            document.getElementById('formulario_responsavelSel_id').value = "";
            document.getElementById('formulario_responsavelSel_sigla').value = "";
            document.getElementById('formulario_responsavelSel_descricao').value = "";
            document.getElementById('responsavelSelSpan').innerHTML = "";

            document.getElementById('formulario_cpOrgaoSel_id').value = "";
            document.getElementById('formulario_cpOrgaoSel_sigla').value = "";
            document.getElementById('formulario_cpOrgaoSel_descricao').value = "";
            document.getElementById('cpOrgaoSelSpan').innerHTML = "";

            document.getElementById('responsavelSelecionado').innerHTML = "";

            document.getElementById('lotaResponsavel').style.display = 'none';
            document.getElementById('responsavel').style.display = 'none';
            document.getElementById('cpOrgao').style.display = 'none';
            Array.from(document.getElementsByClassName('campo-orgao-externo')).forEach(el => el.style.display = 'none');
        }

        function validar() {
            let elementoResponsavelSelecionado = getResponsavelSelecionado();
            let siglaResponsavelSelecionado = getSiglaResponsavelSelecionado();

            if (siglaResponsavelSelecionado.trim() === '') {
                sigaModal.alerta('Selecione o destinatário da tramitação');
                return;
            }

            if (elementoResponsavelSelecionado.id !== 'cpOrgao') {
                let lotacaoIsSupensa;

                if (elementoResponsavelSelecionado.id === 'lotaResponsavel') {
                    lotacaoIsSupensa = verificarSeLotacaoEstaSuspensa(siglaResponsavelSelecionado, '');
                } else if (elementoResponsavelSelecionado.id === 'responsavel') {
                    let matriculaResponsavel = siglaResponsavelSelecionado;
                    lotacaoIsSupensa = verificarSeLotacaoEstaSuspensa('', matriculaResponsavel);
                }

                if (lotacaoIsSupensa == 1) {
                    sigaModal.alerta('Lotação suspensa para tramitação');
                    return;
                } else if (lotacaoIsSupensa != 0) {
                    sigaModal.alerta('Não foi possível obter a lotação para tramitação');
                    return;
                }
            }

            let checkedElements = $("input[name='documentosSelecionados']:checked");
            if (checkedElements.length === 0) {
                sigaModal.alerta('Selecione pelo menos um documento');
            } else {
                updateResponsavelSelecionado();
                sigaModal.abrir('confirmacaoModal');
            }
        }

        function verificarSeLotacaoEstaSuspensa(sigla, matricula) {
            let jqXHR = $.ajax({
                url: '/siga/app/lotacao/isSuspensa?sigla=' + sigla + '&matricula=' + matricula,
                type: 'GET',
                async: false,
                success: function (result) {
                },
                error: function (result) {
                    console.log(result);
                }
            });

            return jqXHR.responseText;
        }

        let siglasDocumentosTramitados = [];
        let errosDocumentosNaoTramitadosMap = new Map();

        function confirmar() {
            document.getElementById('btnOk').disabled = true;
            sigaModal.fechar('confirmacaoModal');
            enviarParaTramitacaoLote();
        }

        function enviarParaTramitacaoLote() {

            let lotacaoDestinoSelSigla = document.getElementById('formulario_lotaResponsavelSel_sigla').value;
            lotacaoDestinoSelSigla = lotacaoDestinoSelSigla.replace('-', '');

            let usuarioDestinoSelSigla = document.getElementById('formulario_responsavelSel_sigla').value;
            let orgaoDestinoSelSigla = document.getElementById('formulario_cpOrgaoSel_sigla').value;

            let dtDevolucaoMovString = document.getElementsByName('dtDevolucaoMovString')[0].value;
            if(dtDevolucaoMovString.trim() !== ""){
                dtDevolucaoMovString = formataDataString(dtDevolucaoMovString);        
            }
            
            let obsOrgao = document.getElementById('obsOrgao').value;


            process.reset();

            process.push(function () {
                $('#progressModal').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            });

            Array.from($(".chkDocumento:checkbox").filter(":checked")).forEach(
                chk => {
                    process.push(function () {
                        return tramitarDocumentoPost(chk.value, lotacaoDestinoSelSigla, usuarioDestinoSelSigla,
                            orgaoDestinoSelSigla, dtDevolucaoMovString, obsOrgao);

                    });
                    process.push(function () {
                        chk.checked = false;
                    });
                }
            );

            process.push(function () {
                sigaModal.fechar('progressModal');
                sigaSpinner.mostrar();
                enviarParaListagemDocumentosTramitados();
            });

            process.run();

        }

        function formataDataString(data) {
            data = data.replaceAll('/', '');

            let dia = data.substring(0, 2);
            let mes = data.substring(2, 4);
            let ano = data.substring(4, data.length);
            
            const dataFormatada = new Date(ano, mes-1, dia).toISOString().split('T')[0];
            
            return dataFormatada;
        }

        function tramitarDocumentoPost(documentoSelSigla, lotacaoDestinoSelSigla, usuarioDestinoSelSigla,
                                       orgaoDestinoSelSigla, dtDevolucaoMovString, obsOrgao) {
            $.ajax({
                url: '/sigaex/api/v1/documentos/' + documentoSelSigla + '/tramitar',
                type: 'POST',
                async: false,
                data: {
                    sigla: documentoSelSigla,
                    lotacao: lotacaoDestinoSelSigla,
                    matricula: usuarioDestinoSelSigla,
                    orgao: orgaoDestinoSelSigla,
                    observacao: obsOrgao,
                    dataDevolucao: dtDevolucaoMovString
                },
                dataType: 'json',
                success: function () {
                    siglasDocumentosTramitados.push(documentoSelSigla);
                },
                error: function (response) {
                    errosDocumentosNaoTramitadosMap.set(documentoSelSigla, response.responseJSON.errormsg);
                }
            });
        }

        function enviarParaListagemDocumentosTramitados() {
            document.getElementsByName('siglasDocumentosTramitados')[0].value = siglasDocumentosTramitados;

            let errosDocumentosNaoTramitadosJson = JSON.stringify(Object.fromEntries(errosDocumentosNaoTramitadosMap));
            document.getElementsByName('errosDocumentosNaoTramitadosJson')[0].value = errosDocumentosNaoTramitadosJson;

            document.frm.submit();
        }

        let process = {
            steps: [],
            index: 0,
            title: "Executando a tramitação em lote dos documentos selecionados",
            errormsg: "Não foi possível completar a operação",
            urlRedirect: null,
            reset: function () {
                this.steps = [];
                this.index = 0;
            },
            push: function (x) {
                this.steps.push(x);
            },
            run: function () {
                this.progressbar = $('#progressbar-ad').progressbar();
                this.nextStep();
            },
            finalize: function () {
            },
            nextStep: function () {
                if (typeof this.steps[this.index] == 'string')
                    eval(this.steps[this.index++]);
                else {
                    let ret = this.steps[this.index++]();
                    if ((typeof ret == 'string') && ret != "OK") {
                        this.finalize();
                        alert(ret, 0, this.errormsg);
                        return;
                    }
                }

                this.progressbar.progressbar("value",
                    100 * (this.index / this.steps.length));

                if (this.index != this.steps.length) {
                    let me = this;
                    window.setTimeout(function () {
                        me.nextStep();
                    }, 100);
                } else {
                    this.finalize();
                }
            }
        };

    </script>
</siga:pagina>