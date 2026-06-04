class AiAnalysisResult {
  final String resultId;
  final String caseNumber;
  final String message;
  final bool success;
  final CaseSummary? caseSummary;
  final List<Defendant> defendants;
  final List<Charge> charges;
  final List<Incident> incidents;
  final List<Evidence> evidences;
  final List<WitnessStatement> witnessStatements;
  final List<Confession> confessions;
  final List<LabReport> labReports;
  final List<CriminalProceeding> criminalProceedings;
  final List<DefenseDocument> defenseDocuments;
  final ProceduralAudit? proceduralAudit;
  final List<String> completedAgents;
  final List<String> processingErrors;
  final String? processedAt;

  const AiAnalysisResult({
    required this.resultId,
    required this.caseNumber,
    required this.message,
    required this.success,
    this.caseSummary,
    this.defendants = const [],
    this.charges = const [],
    this.incidents = const [],
    this.evidences = const [],
    this.witnessStatements = const [],
    this.confessions = const [],
    this.labReports = const [],
    this.criminalProceedings = const [],
    this.defenseDocuments = const [],
    this.proceduralAudit,
    this.completedAgents = const [],
    this.processingErrors = const [],
    this.processedAt,
  });

  factory AiAnalysisResult.fromJson(Map<String, dynamic> json) {
    // POST response has 'resultId', GET response has 'id'
    final id = (json['resultId'] ?? json['id'] ?? '').toString();
    
    // POST response has a nested 'caseSummary' object. GET response flattens these fields.
    CaseSummary? summaryObj;
    if (json['caseSummary'] != null) {
      summaryObj = CaseSummary.fromJson(json['caseSummary']);
    } else {
      // Try parsing from flattened fields
      if (json['court'] != null || json['prosecutorName'] != null) {
        summaryObj = CaseSummary(
          caseId: id,
          court: (json['court'] ?? '').toString(),
          courtLevel: (json['courtLevel'] ?? '').toString(),
          jurisdiction: (json['jurisdiction'] ?? '').toString(),
          filingDate: (json['filingDate'] ?? '').toString(), // Might not exist in GET
          prosecutorName: (json['prosecutorName'] ?? '').toString(),
          suggestedVerdict: json['suggestedVerdict'] != null
              ? SuggestedVerdict.fromJson(json['suggestedVerdict'])
              : null,
          defendantCount: (json['defendantCount'] as num?)?.toInt() ?? 0,
          chargeCount: (json['chargeCount'] as num?)?.toInt() ?? 0,
          hasProceduralViolations: json['hasProceduralViolations'] == true,
        );
      }
    }

    return AiAnalysisResult(
      resultId: id,
      caseNumber: (json['caseNumber'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      success: json['success'] == true,
      caseSummary: summaryObj,
      defendants: _parseList(json['defendants'], Defendant.fromJson),
      charges: _parseList(json['charges'], Charge.fromJson),
      incidents: _parseList(json['incidents'], Incident.fromJson),
      evidences: _parseList(json['evidences'], Evidence.fromJson),
      witnessStatements:
          _parseList(json['witnessStatements'], WitnessStatement.fromJson),
      confessions: _parseList(json['confessions'], Confession.fromJson),
      labReports: _parseList(json['labReports'], LabReport.fromJson),
      criminalProceedings:
          _parseList(json['criminalProceedings'], CriminalProceeding.fromJson),
      defenseDocuments:
          _parseList(json['defenseDocuments'], DefenseDocument.fromJson),
      proceduralAudit: json['proceduralAudit'] != null
          ? ProceduralAudit.fromJson(json['proceduralAudit'])
          : null,
      completedAgents: _parseStringOrList(json['completedAgents']),
      processingErrors: _parseStringOrList(json['processingErrors']),
      processedAt: json['processedAt']?.toString() ?? json['createdAt']?.toString(),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────

List<String> _parseStringOrList(dynamic data) {
  if (data is List) {
    return data.map((e) => e.toString()).toList();
  } else if (data is String) {
    if (data.trim().isEmpty) return [];
    return data.split(',').map((e) => e.trim()).toList();
  }
  return [];
}

List<T> _parseList<T>(
    dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data is List) {
    return data
        .whereType<Map<String, dynamic>>()
        .map((e) => fromJson(e))
        .toList();
  }
  return [];
}

List<String> _parseStringList(dynamic data) {
  if (data is List) {
    return data.map((e) => e.toString()).toList();
  }
  return [];
}

// ─── Case Summary ─────────────────────────────────────────────────────

class CaseSummary {
  final String caseId;
  final String court;
  final String courtLevel;
  final String jurisdiction;
  final String filingDate;
  final String prosecutorName;
  final SuggestedVerdict? suggestedVerdict;
  final int defendantCount;
  final int chargeCount;
  final bool hasProceduralViolations;

  const CaseSummary({
    required this.caseId,
    required this.court,
    required this.courtLevel,
    required this.jurisdiction,
    required this.filingDate,
    required this.prosecutorName,
    this.suggestedVerdict,
    required this.defendantCount,
    required this.chargeCount,
    required this.hasProceduralViolations,
  });

  factory CaseSummary.fromJson(Map<String, dynamic> json) {
    return CaseSummary(
      caseId: (json['caseId'] ?? '').toString(),
      court: (json['court'] ?? '').toString(),
      courtLevel: (json['courtLevel'] ?? '').toString(),
      jurisdiction: (json['jurisdiction'] ?? '').toString(),
      filingDate: (json['filingDate'] ?? '').toString(),
      prosecutorName: (json['prosecutorName'] ?? '').toString(),
      suggestedVerdict: json['suggestedVerdict'] != null
          ? SuggestedVerdict.fromJson(json['suggestedVerdict'])
          : null,
      defendantCount: (json['defendantCount'] as num?)?.toInt() ?? 0,
      chargeCount: (json['chargeCount'] as num?)?.toInt() ?? 0,
      hasProceduralViolations: json['hasProceduralViolations'] == true,
    );
  }
}

class SuggestedVerdict {
  final String verdict;
  final String recommendedPenalty;
  final List<PerChargeRuling> perChargeRulings;
  final String operativeText;
  final double confidenceScore;

  const SuggestedVerdict({
    required this.verdict,
    required this.recommendedPenalty,
    this.perChargeRulings = const [],
    required this.operativeText,
    required this.confidenceScore,
  });

  factory SuggestedVerdict.fromJson(Map<String, dynamic> json) {
    return SuggestedVerdict(
      verdict: (json['verdict'] ?? '').toString(),
      recommendedPenalty: (json['recommended_penalty'] ?? '').toString(),
      perChargeRulings:
          _parseList(json['per_charge_rulings'], PerChargeRuling.fromJson),
      operativeText: (json['operative_text'] ?? '').toString(),
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PerChargeRuling {
  final String verdict;
  final String penalty;
  final String reasoning;
  final String chargeDescription;

  const PerChargeRuling({
    required this.verdict,
    required this.penalty,
    required this.reasoning,
    required this.chargeDescription,
  });

  factory PerChargeRuling.fromJson(Map<String, dynamic> json) {
    return PerChargeRuling(
      verdict: (json['verdict'] ?? '').toString(),
      penalty: (json['penalty'] ?? '').toString(),
      reasoning: (json['reasoning'] ?? '').toString(),
      chargeDescription: (json['charge_description'] ?? '').toString(),
    );
  }
}

// ─── Defendant ────────────────────────────────────────────────────────

class Defendant {
  final String name;
  final String alias;
  final String gender;
  final int age;
  final String occupation;
  final String nationality;
  final String address;
  final String nationalId;
  final String dateOfBirth;
  final String complicityRole;

  const Defendant({
    required this.name,
    required this.alias,
    required this.gender,
    required this.age,
    required this.occupation,
    required this.nationality,
    required this.address,
    required this.nationalId,
    required this.dateOfBirth,
    required this.complicityRole,
  });

  factory Defendant.fromJson(Map<String, dynamic> json) {
    return Defendant(
      name: (json['name'] ?? '').toString(),
      alias: (json['alias'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
      age: (json['age'] as num?)?.toInt() ?? 0,
      occupation: (json['occupation'] ?? '').toString(),
      nationality: (json['nationality'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      nationalId: (json['national_id'] ?? '').toString(),
      dateOfBirth: (json['date_of_birth'] ?? '').toString(),
      complicityRole: (json['complicity_role'] ?? '').toString(),
    );
  }
}

// ─── Charge ───────────────────────────────────────────────────────────

class Charge {
  final String description;
  final String lawCode;
  final String articleNumber;
  final String incidentType;
  final String chargeClassification;
  final bool attemptFlag;
  final String chargeDate;
  final String chargeLocation;
  final List<String> linkedDefendantNames;

  const Charge({
    required this.description,
    required this.lawCode,
    required this.articleNumber,
    required this.incidentType,
    required this.chargeClassification,
    required this.attemptFlag,
    required this.chargeDate,
    required this.chargeLocation,
    this.linkedDefendantNames = const [],
  });

  factory Charge.fromJson(Map<String, dynamic> json) {
    return Charge(
      description: (json['description'] ?? '').toString(),
      lawCode: (json['law_code'] ?? '').toString(),
      articleNumber: (json['article_number'] ?? '').toString(),
      incidentType: (json['incident_type'] ?? '').toString(),
      chargeClassification: (json['charge_classification'] ?? '').toString(),
      attemptFlag: json['attempt_flag'] == true,
      chargeDate: (json['charge_date'] ?? '').toString(),
      chargeLocation: (json['charge_location'] ?? '').toString(),
      linkedDefendantNames: _parseStringList(json['linked_defendant_names']),
    );
  }
}

// ─── Incident ─────────────────────────────────────────────────────────

class Incident {
  final String incidentType;
  final String incidentDate;
  final String incidentLocation;
  final String incidentDescription;
  final List<String> perpetratorNames;
  final List<String> victimNames;

  const Incident({
    required this.incidentType,
    required this.incidentDate,
    required this.incidentLocation,
    required this.incidentDescription,
    this.perpetratorNames = const [],
    this.victimNames = const [],
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      incidentType: (json['incident_type'] ?? '').toString(),
      incidentDate: (json['incident_date'] ?? '').toString(),
      incidentLocation: (json['incident_location'] ?? '').toString(),
      incidentDescription: (json['incident_description'] ?? '').toString(),
      perpetratorNames: _parseStringList(json['perpetrator_names']),
      victimNames: _parseStringList(json['victim_names']),
    );
  }
}

// ─── Evidence ─────────────────────────────────────────────────────────

class Evidence {
  final String description;
  final String evidenceType;
  final String detailedText;
  final String seizureDate;
  final String seizureLocation;
  final String seizedBy;
  final bool seizureWarrantPresent;
  final String linkedDefendantName;

  const Evidence({
    required this.description,
    required this.evidenceType,
    required this.detailedText,
    required this.seizureDate,
    required this.seizureLocation,
    required this.seizedBy,
    required this.seizureWarrantPresent,
    required this.linkedDefendantName,
  });

  factory Evidence.fromJson(Map<String, dynamic> json) {
    return Evidence(
      description: (json['description'] ?? '').toString(),
      evidenceType: (json['evidence_type'] ?? '').toString(),
      detailedText: (json['detailed_text'] ?? '').toString(),
      seizureDate: (json['seizure_date'] ?? '').toString(),
      seizureLocation: (json['seizure_location'] ?? '').toString(),
      seizedBy: (json['seized_by'] ?? '').toString(),
      seizureWarrantPresent: json['seizure_warrant_present'] == true,
      linkedDefendantName: (json['linked_defendant_name'] ?? '').toString(),
    );
  }
}

// ─── WitnessStatement ─────────────────────────────────────────────────

class WitnessStatement {
  final String occupation;
  final String witnessName;
  final String witnessType;
  final String relationToDefendant;
  final String statementSummary;
  final bool wasSwornIn;
  final bool presenceAtScene;

  const WitnessStatement({
    required this.occupation,
    required this.witnessName,
    required this.witnessType,
    required this.relationToDefendant,
    required this.statementSummary,
    required this.wasSwornIn,
    required this.presenceAtScene,
  });

  factory WitnessStatement.fromJson(Map<String, dynamic> json) {
    return WitnessStatement(
      occupation: (json['occupation'] ?? '').toString(),
      witnessName: (json['witness_name'] ?? '').toString(),
      witnessType: (json['witness_type'] ?? '').toString(),
      relationToDefendant: (json['relation_to_defendant'] ?? '').toString(),
      statementSummary: (json['statement_summary'] ?? '').toString(),
      wasSwornIn: json['was_sworn_in'] == true,
      presenceAtScene: json['presence_at_scene'] == true,
    );
  }
}

// ─── Confession ───────────────────────────────────────────────────────

class Confession {
  final String text;
  final String defendantName;
  final String confessionDate;
  final String confessionStage;
  final bool legalCounselPresent;
  final bool coercionClaimed;
  final List<String> keyAdmissions;

  const Confession({
    required this.text,
    required this.defendantName,
    required this.confessionDate,
    required this.confessionStage,
    required this.legalCounselPresent,
    required this.coercionClaimed,
    this.keyAdmissions = const [],
  });

  factory Confession.fromJson(Map<String, dynamic> json) {
    return Confession(
      text: (json['text'] ?? '').toString(),
      defendantName: (json['defendant_name'] ?? '').toString(),
      confessionDate: (json['confession_date'] ?? '').toString(),
      confessionStage: (json['confession_stage'] ?? '').toString(),
      legalCounselPresent: json['legal_counsel_present'] == true,
      coercionClaimed: json['coercion_claimed'] == true,
      keyAdmissions: _parseStringList(json['key_admissions']),
    );
  }
}

// ─── LabReport ────────────────────────────────────────────────────────

class LabReport {
  final String result;
  final String reportType;
  final String reportNumber;
  final String examinationDate;
  final String examinerName;
  final String linkedDefendantName;

  const LabReport({
    required this.result,
    required this.reportType,
    required this.reportNumber,
    required this.examinationDate,
    required this.examinerName,
    required this.linkedDefendantName,
  });

  factory LabReport.fromJson(Map<String, dynamic> json) {
    return LabReport(
      result: (json['result'] ?? '').toString(),
      reportType: (json['report_type'] ?? '').toString(),
      reportNumber: (json['report_number'] ?? '').toString(),
      examinationDate: (json['examination_date'] ?? '').toString(),
      examinerName: (json['examiner_name'] ?? '').toString(),
      linkedDefendantName: (json['linked_defendant_name'] ?? '').toString(),
    );
  }
}

// ─── CriminalProceeding ──────────────────────────────────────────────

class CriminalProceeding {
  final String description;
  final String procedureType;
  final bool warrantPresent;
  final String conductingOfficer;

  const CriminalProceeding({
    required this.description,
    required this.procedureType,
    required this.warrantPresent,
    required this.conductingOfficer,
  });

  factory CriminalProceeding.fromJson(Map<String, dynamic> json) {
    return CriminalProceeding(
      description: (json['description'] ?? '').toString(),
      procedureType: (json['procedure_type'] ?? '').toString(),
      warrantPresent: json['warrant_present'] == true,
      conductingOfficer: (json['conducting_officer'] ?? '').toString(),
    );
  }
}

// ─── DefenseDocument ──────────────────────────────────────────────────

class DefenseDocument {
  final String submittedBy;
  final String defendantName;
  final List<String> formalDefenses;
  final List<String> substantiveDefenses;
  final bool alibiClaimed;
  final String alibiDescription;

  const DefenseDocument({
    required this.submittedBy,
    required this.defendantName,
    this.formalDefenses = const [],
    this.substantiveDefenses = const [],
    required this.alibiClaimed,
    required this.alibiDescription,
  });

  factory DefenseDocument.fromJson(Map<String, dynamic> json) {
    return DefenseDocument(
      submittedBy: (json['submitted_by'] ?? '').toString(),
      defendantName: (json['defendant_name'] ?? '').toString(),
      formalDefenses: _parseStringList(json['formal_defenses']),
      substantiveDefenses: _parseStringList(json['substantive_defenses']),
      alibiClaimed: json['alibi_claimed'] == true,
      alibiDescription: (json['alibi_description'] ?? '').toString(),
    );
  }
}

// ─── ProceduralAudit ──────────────────────────────────────────────────

class ProceduralAudit {
  final List<ProceduralViolation> violations;
  final String overallAssessment;
  final List<String> criticalNullities;
  final List<String> kgArticlesUsed;
  final List<ExcludedDefenseClaim> excludedDefenseClaims;

  const ProceduralAudit({
    this.violations = const [],
    required this.overallAssessment,
    this.criticalNullities = const [],
    this.kgArticlesUsed = const [],
    this.excludedDefenseClaims = const [],
  });

  factory ProceduralAudit.fromJson(Map<String, dynamic> json) {
    return ProceduralAudit(
      violations:
          _parseList(json['violations'], ProceduralViolation.fromJson),
      overallAssessment: (json['overall_assessment'] ?? '').toString(),
      criticalNullities: _parseStringList(json['critical_nullities']),
      kgArticlesUsed: _parseStringList(json['kg_articles_used']),
      excludedDefenseClaims: _parseList(
          json['excluded_defense_claims'], ExcludedDefenseClaim.fromJson),
    );
  }
}

class ProceduralViolation {
  final String procedureType;
  final String issueDescription;
  final String nullityType;
  final String nullityEffect;
  final String articleBasis;
  final String conductingOfficer;

  const ProceduralViolation({
    required this.procedureType,
    required this.issueDescription,
    required this.nullityType,
    required this.nullityEffect,
    required this.articleBasis,
    required this.conductingOfficer,
  });

  factory ProceduralViolation.fromJson(Map<String, dynamic> json) {
    return ProceduralViolation(
      procedureType: (json['procedure_type'] ?? '').toString(),
      issueDescription: (json['issue_description'] ?? '').toString(),
      nullityType: (json['nullity_type'] ?? '').toString(),
      nullityEffect: (json['nullity_effect'] ?? '').toString(),
      articleBasis: (json['article_basis'] ?? '').toString(),
      conductingOfficer: (json['conducting_officer'] ?? '').toString(),
    );
  }
}

class ExcludedDefenseClaim {
  final String claim;
  final String reason;

  const ExcludedDefenseClaim({
    required this.claim,
    required this.reason,
  });

  factory ExcludedDefenseClaim.fromJson(Map<String, dynamic> json) {
    return ExcludedDefenseClaim(
      claim: (json['claim'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
    );
  }
}
