
#!/bin/bash

# 配置
REPO_OWNER="${{ github.repository_owner }}"
REPO_NAME="${{ github.event.repository.name }}"
WORKFLOW_NAME="Main Branch Checks & Builds" # 对应 main.yml 的 name
KEEP_LAST_N_RUNS=3 # 保留最近 N 次构建

echo "Starting artifact cleanup for workflow: $WORKFLOW_NAME"

# 获取工作流 ID
WORKFLOW_ID=$(gh api \
  --header "Accept: application/vnd.github.v3+json" \
  /repos/$REPO_OWNER/$REPO_NAME/actions/workflows \
  --jq ".workflows[] | select(.name == \"$WORKFLOW_NAME\").id")

if [ -z "$WORKFLOW_ID" ]; then
  echo "Error: Workflow [33m$WORKFLOW_NAME[0m not found. Exiting."
  exit 1
fi

echo "Found workflow [32m$WORKFLOW_NAME[0m with ID [32m$WORKFLOW_ID[0m."

# 获取所有成功的 workflow runs，按创建时间倒序排列
# 过滤掉当前正在运行的 run，以及最近 KEEP_LAST_N_RUNS 次的 run
RUNS_TO_DELETE=$(gh api \
  --header "Accept: application/vnd.github.v3+json" \
  /repos/$REPO_OWNER/$REPO_NAME/actions/workflows/$WORKFLOW_ID/runs \
  --jq ".workflow_runs[] | select(.status == \"completed\" and .conclusion == \"success\") | .id" \
  | tail -n +$((KEEP_LAST_N_RUNS + 1)))

if [ -z "$RUNS_TO_DELETE" ]; then
  echo "No old successful workflow runs to delete for [33m$WORKFLOW_NAME[0m. Exiting."
  exit 0
fi

echo "Found old successful workflow runs to delete:"
echo "$RUNS_TO_DELETE"

# 逐个删除旧的 workflow runs
for RUN_ID in $RUNS_TO_DELETE; do
  echo "Deleting workflow run [31m$RUN_ID[0m..."
  gh api \
    --method DELETE \
    --header "Accept: application/vnd.github.v3+json" \
    /repos/$REPO_OWNER/$REPO_NAME/actions/runs/$RUN_ID
  echo "Workflow run [31m$RUN_ID[0m deleted."
done

echo "Artifact cleanup completed."
