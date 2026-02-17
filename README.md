# Курсовая работа на профессии "DevOps-инженер с нуля" - Марченко Николай

## Схема проекта

[Схема проекта](https://github.com/Doskaks/project_kr_my_site/blob/master/%D0%A1%D1%85%D0%B5%D0%BC%D0%B0%20%D0%BF%D1%80%D0%BE%D0%B5%D0%BA%D1%82%D0%B0.pdf)

## Доступы к проекту

1. [Адрес сайта](http://158.160.204.114) -  демонстрационная страница;

2. [Grafana](http://93.77.177.6:3000/d/xfpJB9FGz/node-exporter-dashboard-en-20201010-starsl-cn?orgId=1&var-origin_prometheus=&var-job=node&var-hostname=web-a&var-node=10.0.1.13%3A9100&var-device=All&var-interval=2m&var-maxmount=%2F&var-show_hostname=web-a&var-total=6&from=1771214527320&to=1771257727320)  - дашборд

3. [Kibana](http://93.77.186.124:5601/app/dashboards#/view/9eeb2770-08b5-11f1-a79a-755ce5a13aac?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now-15m,to:now))&_a=(description:'',filters:!(),fullScreenMode:!f,options:(hidePanelTitles:!f,syncColors:!f,useMargins:!t),panels:!((embeddableConfig:(attributes:(references:!((id:'38724fd0-0844-11f1-a79a-755ce5a13aac',name:indexpattern-datasource-current-indexpattern,type:index-pattern),(id:'38724fd0-0844-11f1-a79a-755ce5a13aac',name:indexpattern-datasource-layer-9dc39921-01f5-42a7-8d57-147fcdea88ad,type:index-pattern)),state:(datasourceStates:(indexpattern:(layers:('9dc39921-01f5-42a7-8d57-147fcdea88ad':(columnOrder:!('42ef9b82-b504-49c7-8481-807c3e21bbaa',cba3fb35-8471-462c-a5d4-268a68475b5f,f78c456b-2e14-483e-869f-c75bb6ca7d9d),columns:('42ef9b82-b504-49c7-8481-807c3e21bbaa':(dataType:string,isBucketed:!t,label:'Top%20values%20of%20fileset.name',operationType:terms,params:(missingBucket:!f,orderBy:(columnId:f78c456b-2e14-483e-869f-c75bb6ca7d9d,type:column),orderDirection:desc,otherBucket:!t,size:5),scale:ordinal,sourceField:fileset.name),cba3fb35-8471-462c-a5d4-268a68475b5f:(dataType:date,isBucketed:!t,label:'@timestamp',operationType:date_histogram,params:(interval:auto),scale:interval,sourceField:'@timestamp'),f78c456b-2e14-483e-869f-c75bb6ca7d9d:(dataType:number,isBucketed:!f,label:'Count%20of%20records',operationType:count,scale:ratio,sourceField:Records)),incompleteColumns:())))),filters:!(),query:(language:kuery,query:''),visualization:(axisTitlesVisibilitySettings:(x:!t,yLeft:!t,yRight:!t),fittingFunction:None,gridlinesVisibilitySettings:(x:!t,yLeft:!t,yRight:!t),labelsOrientation:(x:0,yLeft:0,yRight:0),layers:!((accessors:!(f78c456b-2e14-483e-869f-c75bb6ca7d9d),layerId:'9dc39921-01f5-42a7-8d57-147fcdea88ad',layerType:data,position:top,seriesType:bar_stacked,showGridlines:!f,splitAccessor:'42ef9b82-b504-49c7-8481-807c3e21bbaa',xAccessor:cba3fb35-8471-462c-a5d4-268a68475b5f)),legend:(isVisible:!t,position:right),preferredSeriesType:bar_stacked,tickLabelsVisibilitySettings:(x:!t,yLeft:!t,yRight:!t),valueLabels:hide,yLeftExtent:(mode:full),yRightExtent:(mode:full))),title:'',type:lens,visualizationType:lnsXY),enhancements:(),hidePanelTitles:!f),gridData:(h:15,i:'6f01eecd-6f6e-4a04-8240-54975446c9f0',w:24,x:0,y:0),panelIndex:'6f01eecd-6f6e-4a04-8240-54975446c9f0',title:acces,type:lens,version:'7.17.13')),query:(language:kuery,query:''),tags:!(),timeRestore:!f,title:'%D0%98%D0%BD%D1%84%D0%BE%D1%80%D0%BC%D0%B0%D1%86%D0%B8%D1%8F%20%D0%BE%20%D0%BB%D0%BE%D0%B3%D0%B0%D1%85',viewMode:view)) - дашборд



4. terraform output
```
alb_public_ip = "158.160.204.114"
bastion_public_ip = "93.77.186.175"
elasticsearch_ip = "10.0.1.33"
grafana_public_ip = "93.77.177.6"
kibana_public_ip = "93.77.186.124"
prometheus_ip = "10.0.1.19"
web_servers_ips = {
  "web-a" = "10.0.1.13"
  "web-b" = "10.0.2.30"
```


Подтверждение ресурсов работы серверов:

Развернутые ресурсы в YandexCloud
![Развернутые ресурсы в YandexCloud]()

Работа ресурса Filebeat на web-a:
![Работа ресурса Filebeat на web-a](https://github.com/Doskaks/project_kr_my_site/blob/master/%D0%A0%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%D1%80%D0%B5%D1%81%D1%83%D1%80%D1%81%D0%B0%20Filebeat%20%D0%BD%D0%B0%20web-a.jpg)

Работа ресурса Filebeat на web-b:
![Работа ресурса Filebeat на web-b](https://github.com/Doskaks/project_kr_my_site/blob/master/%D0%A0%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%D1%80%D0%B5%D1%81%D1%83%D1%80%D1%81%D0%B0%20Filebeat%20%D0%BD%D0%B0%20web-b.jpg)

Работа ресурса Prometheus
![Работа ресурса Prometheus](https://github.com/Doskaks/project_kr_my_site/blob/master/%D0%A0%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%D1%80%D0%B5%D1%81%D1%83%D1%80%D1%81%D0%B0%20Prometheus.jpg)

Работа ресурса Web-a, Web-b:
![Работа ресурса Web-a, Web-b.jpg](https://github.com/Doskaks/project_kr_my_site/blob/master/%D0%A0%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%D1%80%D0%B5%D1%81%D1%83%D1%80%D1%81%D0%B0%20Web-a%2C%20Web-b.jpg)

Работа ресурса nginx-log-exporter:
![Работа ресурса nginx-log-exporter.jpg](https://github.com/Doskaks/project_kr_my_site/blob/master/%D0%A0%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%D1%80%D0%B5%D1%81%D1%83%D1%80%D1%81%D0%B0%20nginx-log-exporter.jpg)

Работа ресурса nginx:
![Работа ресурса nginx](https://github.com/Doskaks/project_kr_my_site/blob/master/%D0%A0%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%D1%80%D0%B5%D1%81%D1%83%D1%80%D1%81%D0%B0%20nginx.jpg)



## Резервное копирование

![Резервное копирование]()

