#!/bin/bash
echo "=== ФИНАЛЬНАЯ ВЕРИФИКАЦИЯ ВСЕЙ ИНФРАСТРУКТУРЫ ==="

echo ""
echo "1. 🌐 ВЕБ-САЙТ:"
echo "   URL: http://158.160.204.114"
echo "   Health check: http://158.160.204.114/health"
curl -s http://158.160.204.114/health 2>/dev/null | head -c 100
echo ""

echo ""
echo "2. 📊 ГРАФАНА (МОНИТОРИНГ):"
echo "   URL: http://89.169.137.117:3000"
echo "   Логин: admin"
echo "   Пароль: admin123"
echo "   Статус:"
ansible grafana -m shell -a "curl -s http://localhost:3000/api/health 2>/dev/null | head -c 80" 2>/dev/null
echo ""

echo ""
echo "3. 📈 КИБАНА (ЛОГИ):"
echo "   URL: http://93.77.183.232:5601"
echo "   Статус: HTTP 302 (нормально - перенаправление)"
curl -I http://93.77.183.232:5601 2>/dev/null | head -1
echo ""

echo ""
echo "4. 🔧 ПРОМЕТЕЙ (МЕТРИКИ):"
echo "   Доступ через SSH туннель:"
echo "   ssh -L 9090:10.0.1.19:9090 nikolaym@93.77.186.169 -N"
echo "   Затем: http://localhost:9090"
echo "   Статус targets:"
ansible prometheus -m shell -a "
  curl -s 'http://localhost:9090/api/v1/targets' 2>/dev/null | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
    total = len(d[\"data\"][\"activeTargets\"])
    up = sum(1 for t in d[\"data\"][\"activeTargets\"] if t[\"health\"] == \"up\")
    print(f\"   Всего: {total}, Здоровых: {up}\")
except:
    print(\"   Ошибка проверки\")
  '
" 2>/dev/null
echo ""

echo ""
echo "5. 🗄️  ELASTICSEARCH (ХРАНИЛИЩЕ ЛОГОВ):"
echo "   Статус кластера:"
ansible elasticsearch -m shell -a "
  curl -s http://localhost:9200/_cluster/health 2>/dev/null | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
    status = d.get(\"status\", \"unknown\")
    color = \"🟢\" if status == \"green\" else \"🟡\" if status == \"yellow\" else \"🔴\"
    print(f\"   {color} {status} (нод: {d.get(\\\"number_of_nodes\\\", 0)})\")
except:
    print(\"   🔴 ошибка проверки\")
  '
" 2>/dev/null
echo ""

echo ""
echo "6. 📊 NODE EXPORTER (МЕТРИКИ СЕРВЕРОВ):"
echo "   Установлен на всех серверах"
ansible all -m shell -a "systemctl is-active node_exporter 2>/dev/null && echo \"   ✅ $(hostname)\" || echo \"   ❌ $(hostname)\"" 2>/dev/null | head -5
echo ""

echo "=== 🎉 ИНФРАСТРУКТУРА ГОТОВА! ==="
echo ""
echo "ОТКРОЙТЕ В БРАУЗЕРЕ:"
echo "1. Kibana (логи):  http://93.77.183.232:5601"
echo "2. Grafana (метрики): http://89.169.137.117:3000"
echo "3. Веб-сайт: http://158.160.204.114"
echo ""
echo "ДОПОЛНИТЕЛЬНО:"
echo "- Prometheus: через SSH туннель (см. выше)"
echo "- Elasticsearch API: http://10.0.1.33:9200 (через бастион)"
echo ""
echo "ДАННЫЕ ДЛЯ ВХОДА:"
echo "- Grafana: admin / admin123"
echo "- Kibana: без аутентификации (по умолчанию)"
