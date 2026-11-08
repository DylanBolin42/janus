import 'package:flutter_test/flutter_test.dart';
import 'package:janus/scheduling/plan_commit_guard.dart';

void main() {
  final generated = DateTime.utc(2026, 11, 8, 9);
  final expires = generated.add(const Duration(minutes: 5));
  PlanStamp stamp({String revision = 'revision-1'}) => PlanStamp(
    planId: 'plan-1',
    userId: 'user-1',
    workspaceId: 'workspace-1',
    inputRevision: revision,
    scoringVersion: 'cardo-v1',
    schedulingVersion: 'scheduler-v1',
    generatedAt: generated,
    validUntil: expires,
  );
  PlanRejection? check({
    String user = 'user-1',
    String workspace = 'workspace-1',
    String revision = 'revision-1',
    String scoring = 'cardo-v1',
    String scheduling = 'scheduler-v1',
    DateTime? now,
  }) => checkPlanCommit(
    plan: stamp(),
    currentUserId: user,
    currentWorkspaceId: workspace,
    currentInputRevision: revision,
    currentScoringVersion: scoring,
    currentSchedulingVersion: scheduling,
    now: now ?? generated,
  );

  test('accepts matching scope, snapshot and versions within validity', () {
    expect(check(), isNull);
    expect(
      check(now: expires.subtract(const Duration(microseconds: 1))),
      isNull,
    );
    expect(stamp().generatedAt.isUtc, isTrue);
    expect(PlanStamp.schemaVersion, 1);
  });
  test('isolates users even when task IDs/revisions collide', () {
    expect(check(user: 'user-2'), PlanRejection.scopeMismatch);
  });
  test('isolates workspaces within the same user', () {
    expect(check(workspace: 'workspace-2'), PlanRejection.scopeMismatch);
  });
  test('rejects changed/deleted tasks, windows or configuration snapshot', () {
    expect(check(revision: 'revision-2'), PlanRejection.staleInputs);
  });
  test(
    'a successful competing write must advance revision and reject replay',
    () {
      expect(check(), isNull);
      expect(
        check(revision: 'revision-after-plan-commit'),
        PlanRejection.staleInputs,
      );
    },
  );
  test('rejects scoring or scheduling version changes', () {
    expect(check(scoring: 'cardo-v2'), PlanRejection.versionMismatch);
    expect(check(scheduling: 'scheduler-v2'), PlanRejection.versionMismatch);
  });
  test('rejects time before generation and at/after expiry', () {
    expect(
      check(now: generated.subtract(const Duration(microseconds: 1))),
      PlanRejection.notYetValid,
    );
    expect(check(now: expires), PlanRejection.expired);
    expect(
      check(now: expires.add(const Duration(seconds: 1))),
      PlanRejection.expired,
    );
  });
  test('rejects missing identity and nonpositive validity', () {
    expect(() => stamp(revision: ''), throwsArgumentError);
    expect(
      () => PlanStamp(
        planId: 'p',
        userId: 'u',
        workspaceId: 'w',
        inputRevision: 'r',
        scoringVersion: 's',
        schedulingVersion: 'v',
        generatedAt: generated,
        validUntil: generated,
      ),
      throwsArgumentError,
    );
  });
}
