import json

def analyze(resources):
    recommendations = []

    for r in resources:
        if r["service"] == "EC2" and r.get("cpu_usage_percent", 100) < 20:
            recommendations.append({
                "resource_id": r["resource_id"],
                "issue": "Low CPU usage",
                "recommendation": "Downsize instance",
                "estimated_savings": f"{int(r['monthly_cost'] * 0.3)}$/month"
            })

        if r["service"] == "EBS" and r.get("volume_type") == "gp2":
            recommendations.append({
                "resource_id": r["resource_id"],
                "issue": "gp2 volume",
                "recommendation": "Migrate to gp3",
                "estimated_savings": f"{int(r['monthly_cost'] * 0.2)}$/month"
            })

    return recommendations


def lambda_handler(event, context):
    with open('/tmp/data.json') as f:
        data = json.load(f)

    results = analyze(data)

    return {
        "statusCode": 200,
        "body": json.dumps(results)
    }