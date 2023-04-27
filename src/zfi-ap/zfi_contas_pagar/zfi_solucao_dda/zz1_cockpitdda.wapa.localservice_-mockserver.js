sap.ui.define(["sap/ui/core/util/MockServer"],function(e){"use strict";var t,r="br/com/trescoracoes/cockpitdda/",a=r+"localService/mockdata";return{init:function(){var n=jQuery.sap.getUriParameters(),o=jQuery.sap.getModulePath(a),s=jQuery.sap.getModulePa+
th(r+"manifest",".json"),i="ZC_FI_COCKPIT_DDA",u=n.get("errorType"),c=u==="badRequest"?400:500,p=jQuery.sap.syncGetJSON(s).data,l=p["sap.app"].dataSources,d=l.mainService,f=jQuery.sap.getModulePath(r+d.settings.localUri.replace(".xml",""),".xml"),g=/.*\/+
$/.test(d.uri)?d.uri:d.uri+"/",m=d.settings.annotations;t=new e({rootUri:g});e.config({autoRespond:true,autoRespondAfter:n.get("serverDelay")||1e3});t.simulate(f,{sMockdataBaseUrl:o,bGenerateMissingMockData:true});var y=t.getRequests(),h=function(e,t,r){+
r.response=function(r){r.respond(e,{"Content-Type":"text/plain;charset=utf-8"},t)}};if(n.get("metadataError")){y.forEach(function(e){if(e.path.toString().indexOf("$metadata")>-1){h(500,"metadata Error",e)}})}if(u){y.forEach(function(e){if(e.path.toString+
().indexOf(i)>-1){h(c,u,e)}})}t.start();jQuery.sap.log.info("Running the app with mock data");if(m&&m.length>0){m.forEach(function(t){var a=l[t],n=a.uri,o=jQuery.sap.getModulePath(r+a.settings.localUri.replace(".xml",""),".xml");new e({rootUri:n,requests+
:[{method:"GET",path:new RegExp("([?#].*)?"),response:function(e){jQuery.sap.require("jquery.sap.xml");var t=jQuery.sap.sjax({url:o,dataType:"xml"}).data;e.respondXML(200,{},jQuery.sap.serializeXML(t));return true}}]}).start()})}},getMockServer:function(+
){return t}}});                                                                                                                                                                                                                                                
//# sourceMappingURL=mockserver.js.map                                                                                                                                                                                                                         