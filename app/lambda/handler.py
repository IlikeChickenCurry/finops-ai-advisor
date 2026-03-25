import json
import boto3
import os

s3 = boto3.client('s3')
bedrock = boto3.client("bedrock-runtime", region_name="us-east-1")

INPUT_BUCKET = os.environ["INPUT_BUCKET"]
INPUT_KEY = os.environ["INPUT_KEY"]
OUTPUT_KEY = os.environ["OUTPUT_KEY"]
BEDROCK_MODEL_ID = os.environ["BEDROCK_MODEL_ID"]


def analyze(resources):
    recommendations = []

    for r in resources:
        if r["service"] == "EC2" and r.get("cpu_usage_percent", 100) < 20:
            recommendations.append({
                "resource_id": r["resource_id"],
                "issue": "Low CPU usage",
                "recommendation": "Downsize instance",
                "estimated_savings": int(r["monthly_cost"] * 0.3)
            })

        if r["service"] == "EBS" and r.get("volume_type") == "gp2":
            recommendations.append({
                "resource_id": r["resource_id"],
                "issue": "gp2 volume",
                "recommendation": "Migrate to gp3",
                "estimated_savings": int(r["monthly_cost"] * 0.2)
            })

    return recommendations


def lambda_handler(event, context):
    try:
        print(f"Reading from bucket={INPUT_BUCKET}, key={INPUT_KEY}")

        response = s3.get_object(Bucket=INPUT_BUCKET, Key=INPUT_KEY)
        data = json.loads(response['Body'].read())

        print(f"Loaded {len(data)} resources")

        response_bedrock = bedrock.invoke_model(
            modelId=BEDROCK_MODEL_ID,
            body=json.dumps({
                "messages": [
                    {
                        "role": "user",
                        "content": [
                            {
                                "text": f"Analyze this cloud cost data and give optimization advice: {data}"
                            }
                        ]
                    }
                ]
            }),
            contentType="application/json",
            accept="application/json"
        )

        result_text = json.loads(response_bedrock["body"].read())

        print(f"Bedrock response: {result_text}")
        results = analyze(data)

        print(f"Generated {len(results)} recommendations")

        s3.put_object(
            Bucket=INPUT_BUCKET,
            Key=OUTPUT_KEY,
            Body=json.dumps(results)
        )

        print(f"Results written to {OUTPUT_KEY}")

        return {
            "statusCode": 200,
            "body": json.dumps(results)
        }

    except Exception as e:
        print(f"Error during execution: {str(e)}")
        raise