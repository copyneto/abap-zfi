sap.ui.define(["sap/m/PDFViewer"],function(e){"use strict";return sap.ui.controller("br.com.trescoracoes.cockpitdda.ext.controller.ListReportExt",{imprimirBoleto:function(a){var r=this.extensionAPI.getSelectedContexts();if(r.length>0){var o=r.reduce(func+
tion(e,a){return a.getObject()},"")}debugger;var t="/sap/opu/odata/SAP/ZFI_BOLETO_DDA_SRV/";var i="DownloadCheckSet(Lifnr='"+o.Supplier+"',Bukrs='"+o.CompanyCode+"',Belnr='"+o.DocNumber+"',Gjahr='"+o.FiscalYear+"',Barcode='"+o.Barcode+"',DataArq='"+o.Dat+
aArq+"',NumDoc='"+o.ReferenceNo.trim()+"')";var n=t+"PdfFileSet(Lifnr='"+o.Supplier+"',Bukrs='"+o.CompanyCode+"',Belnr='"+o.DocNumber+"',Gjahr='"+o.FiscalYear+"',Barcode='"+o.Barcode+"',DataArq='"+o.DataArq+"',NumDoc='"+o.ReferenceNo.trim()+"')/$value";v+
ar l=new sap.ui.model.odata.ODataModel(t,false);l.read(i,null,null,true,function(a){if(!a.Value){return}var r=new e;this.getView().addDependent(r);r.setSource(n);r.setTitle("Boleto DDA");r.open()}.bind(this),function(e){alert("Não foi possível gerar o bo+
leto DDA.");return})},conciliaManual:function(e){var a=this.extensionAPI.getSelectedContexts();var r=[];var o=[];var t=[];var i=[];var n=[];if(a.length>0){for(var l=0;l<a.length;l++){var s=a[l].getObject();if(s.ErrorXblnr=="X"){alert("Nota Fiscal Diverge+
nte, utilize o botão para conciliar!");return}if(s.ErrReason==""){alert("Não é possível executar esta ação.");return}if(s.Supplier!=""){r.push(s.Supplier)}if(s.CompanyCode!=""){o.push(s.CompanyCode)}if(s.DocNumber!=""){t.push(s.DocNumber)}else if(s.ErrRe+
ason="V"){n.push(s.ReferenceNo)}if(s.FiscalYear!=""){i.push(s.FiscalYear)}}}sap.ushell.Container.getService("CrossApplicationNavigation").isNavigationSupported([{target:{shellHash:"conciliacaomanualdda-manage"}}]).done(function(e){e.map(function(e,a){if(+
e.supported===true){var l=sap.ushell&&sap.ushell.Container&&sap.ushell.Container.getService("CrossApplicationNavigation").hrefForExternal({target:{semanticObject:"conciliacaomanualdda",action:"manage"},params:{Supplier:r,CompanyCode:o,DocNumber:t,FiscalY+
ear:i,ReferenceNo:n}});sap.m.URLHelper.redirect(l,false)}else{alert("Usuário sem permissão para acessar o link")}})}).fail(function(){alert("Falha ao acessar o link")})}})});                                                                                 
//# sourceMappingURL=ListReportExt.controller.js.map                                                                                                                                                                                                           