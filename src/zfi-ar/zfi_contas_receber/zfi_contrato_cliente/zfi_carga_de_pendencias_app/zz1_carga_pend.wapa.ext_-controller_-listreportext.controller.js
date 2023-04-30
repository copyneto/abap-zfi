sap.ui.define(["sap/ui/export/Spreadsheet","sap/ui/export/library"],function(e,a){"use strict";return sap.ui.controller("br.com.trescoracoes.cargadependencias.ext.controller.ListReportExt",{onActionUploadFile:function(e){var a=this;var s=new sap.m.Dialog+
({contentWidth:"300px",resizable:true,type:"Message"});s.setTitle("Carregar arquivo Excel");var t="/sap/opu/odata/SAP/ZFI_CARGA_PENDENCIAS_SRV/";var r=new sap.ui.model.odata.ODataModel(t,false);var o=t+"uploadSet";var i=new sap.ui.unified.FileUploader({w+
idth:"100%",fileType:["xlsx","xls","csv"],typeMissmatch:this.handleTypeMissmatch});i.setName("Simple Uploader");i.setUploadUrl(o);i.setSendXHR(true);i.setUseMultipart(false);i.setUploadOnChange(false);var n=new sap.ui.unified.FileUploaderParameter({name:+
"x-csrf-token",value:r.getSecurityToken()});i.insertHeaderParameter(n);var p=new sap.m.Button({text:"Upload",type:"Accept",press:function(){var e=i.getFocusDomRef();var t=e.files[0];if(i.getValue()===""){sap.m.MessageToast.show("Favor selecionar um arqui+
vo");return}var r=new sap.ui.unified.FileUploaderParameter({name:"Content-Type",value:t.type});i.insertHeaderParameter(r);i.insertHeaderParameter(new sap.ui.unified.FileUploaderParameter({name:"SLUG",value:i.getValue()}));var o=function(e){return new Pro+
mise(function(e,t){i.attachUploadComplete(function(r){s.close();s.destroy();if(r.mParameters.status=="200"||r.mParameters.status=="201"||r.mParameters.status=="204"){e()}else{a.showLog(r.mParameters.responseRaw);t()}a.templateBaseExtension.getExtensionAP+
I().refreshTable()}.bind(this));i.upload()}.bind(this))}.bind(this);var n={sActionLabel:"Upload de Arquivo",dataloss:false};this.extensionAPI.securedExecution(o,n)}.bind(this)});var u=new sap.m.Button({text:"Cancelar",type:"Reject",press:function(){s.clo+
se();s.destroy();this.getView().removeAllDependents()}.bind(this)});s.addContent(i);s.setBeginButton(u);s.setEndButton(p);s.open()},handleTypeMissmatch:function(e){var a=e.getSource().getFileType();jQuery.each(a,function(e,s){a[e]="*."+s});var s=a.join("+
, ");sap.m.MessageToast.show("Tipo de arquivo *."+e.getParameter("fileType")+" nao ? suportado. Escolha um dos tipos a seguir: "+s)},showLog:function(e){let a=[];for(const s of e.matchAll(/(?:<message>(.*?)<[/]message>)/gm)){a.push(s[1])}let s=[];for(con+
st a of e.matchAll(/(?:<severity>(.*?)<[/]severity>)/gm)){switch(a[1]){case"error":s.push(sap.ui.core.MessageType.Error);break;case"info":s.push(sap.ui.core.MessageType.Information);break;case"success":s.push(sap.ui.core.MessageType.Success);break;case"w+
arning":s.push(sap.ui.core.MessageType.Warning);break;default:s.push(sap.ui.core.MessageType.None);break}}for(let e=0;e<a.length;e++){if(a[e]=="Ocorreu uma exceção"){continue}sap.ui.getCore().getMessageManager().addMessages(new sap.ui.core.message.Messag+
e({message:a[e],persistent:true,type:s[e]}))}}})});                                                                                                                                                                                                            