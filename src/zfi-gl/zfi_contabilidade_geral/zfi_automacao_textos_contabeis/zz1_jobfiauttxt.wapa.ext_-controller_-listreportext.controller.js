sap.ui.define(["sap/ui/export/library","sap/ui/model/json/JSONModel","sap/m/MessageToast","sap/m/MessageBox"],function(e,t,a,o){"use strict";return sap.ui.controller("br.com.trescoracoes.jobautotxtcontabeis.ext.controller.ListReportExt",{onConsultaLog:fu+
nction(e){var t=sap.ushell&&sap.ushell.Container&&sap.ushell.Container.getService("CrossApplicationNavigation").hrefForExternal({target:{semanticObject:"ApplicationLog",action:"showList"},params:{LogObjectId:"ZFI_AUTOTXTCONT",LogObjectSubId:"FILL_SGTXT"}+
});sap.m.URLHelper.redirect(t,true)},onAbrirConfigRegras:function(e){var t=sap.ushell&&sap.ushell.Container&&sap.ushell.Container.getService("CrossApplicationNavigation").hrefForExternal({target:{semanticObject:"cfgautomacaotxtcontabeis",action:"maintain+
"}});sap.m.URLHelper.redirect(t,true)}})});                                                                                                                                                                                                                    