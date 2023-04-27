sap.ui.define(["sap/ui/core/util/MockServer"],function(e){"use strict";var t,a="br/com/trescoracoes/logagrupafaturas/",r=a+"localService/mockdata";return{init:function(){var n=jQuery.sap.getUriParameters(),o=jQuery.sap.getModulePath(r),s=jQuery.sap.getMo+
dulePath(a+"manifest",".json"),i="ZC_FI_LOGHEADERAGRUPAFATURA",u=n.get("errorType"),p=u==="badRequest"?400:500,c=jQuery.sap.syncGetJSON(s).data,l=c["sap.app"].dataSources,f=l.mainService,d=jQuery.sap.getModulePath(a+f.settings.localUri.replace(".xml","")+
,".xml"),g=/.*\/$/.test(f.uri)?f.uri:f.uri+"/",m=f.settings.annotations;t=new e({rootUri:g});e.config({autoRespond:true,autoRespondAfter:n.get("serverDelay")||1e3});t.simulate(d,{sMockdataBaseUrl:o,bGenerateMissingMockData:true});var y=t.getRequests(),h=+
function(e,t,a){a.response=function(a){a.respond(e,{"Content-Type":"text/plain;charset=utf-8"},t)}};if(n.get("metadataError")){y.forEach(function(e){if(e.path.toString().indexOf("$metadata")>-1){h(500,"metadata Error",e)}})}if(u){y.forEach(function(e){if+
(e.path.toString().indexOf(i)>-1){h(p,u,e)}})}t.start();jQuery.sap.log.info("Running the app with mock data");if(m&&m.length>0){m.forEach(function(t){var r=l[t],n=r.uri,o=jQuery.sap.getModulePath(a+r.settings.localUri.replace(".xml",""),".xml");new e({ro+
otUri:n,requests:[{method:"GET",path:new RegExp("([?#].*)?"),response:function(e){jQuery.sap.require("jquery.sap.xml");var t=jQuery.sap.sjax({url:o,dataType:"xml"}).data;e.respondXML(200,{},jQuery.sap.serializeXML(t));return true}}]}).start()})}},getMock+
Server:function(){return t}}});                                                                                                                                                                                                                                