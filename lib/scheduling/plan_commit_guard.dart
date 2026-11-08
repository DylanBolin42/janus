/// Integration metadata, separate from the pure scheduling result. The caller
/// assigns opaque IDs/revisions from its storage snapshot, never from task IDs.
class PlanStamp {
  PlanStamp({
    required this.planId,
    required this.userId,
    required this.workspaceId,
    required this.inputRevision,
    required this.scoringVersion,
    required this.schedulingVersion,
    required DateTime generatedAt,
    required DateTime validUntil,
  }) : generatedAt = generatedAt.toUtc(),
       validUntil = validUntil.toUtc() {
    if ([
      planId,
      userId,
      workspaceId,
      inputRevision,
      scoringVersion,
      schedulingVersion,
    ].any((value) => value.isEmpty)) {
      throw ArgumentError(
        'Plan identity, scope, revisions and versions are required',
      );
    }
    if (!this.validUntil.isAfter(this.generatedAt)) {
      throw ArgumentError('validUntil must be after generatedAt');
    }
  }

  static const schemaVersion = 1;
  final String planId;
  final String userId;
  final String workspaceId;

  /// Revision of ALL scheduling inputs, including deletions, windows, scoring
  /// configuration and the previously committed plan. Must never be reused.
  final String inputRevision;
  final String scoringVersion;
  final String schedulingVersion;
  final DateTime generatedAt;
  final DateTime validUntil;
}

enum PlanRejection {
  scopeMismatch,
  staleInputs,
  versionMismatch,
  notYetValid,
  expired,
}

/// A precondition check, not authorization or an atomic persistence operation.
/// The integration MUST re-read context and call this inside the same storage
/// transaction/CAS as the write, then advance the revision on successful commit.
PlanRejection? checkPlanCommit({
  required PlanStamp plan,
  required String currentUserId,
  required String currentWorkspaceId,
  required String currentInputRevision,
  required String currentScoringVersion,
  required String currentSchedulingVersion,
  required DateTime now,
}) {
  if (plan.userId != currentUserId || plan.workspaceId != currentWorkspaceId) {
    return PlanRejection.scopeMismatch;
  }
  if (plan.inputRevision != currentInputRevision) {
    return PlanRejection.staleInputs;
  }
  if (plan.scoringVersion != currentScoringVersion ||
      plan.schedulingVersion != currentSchedulingVersion) {
    return PlanRejection.versionMismatch;
  }
  if (now.isBefore(plan.generatedAt)) return PlanRejection.notYetValid;
  if (!now.isBefore(plan.validUntil)) return PlanRejection.expired;
  return null;
}
