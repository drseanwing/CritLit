-- ============================================================================
-- CritLit Test Fixtures
-- ============================================================================
-- Realistic test data for exercise and depression systematic review
-- Uses predictable UUIDs for testing purposes
-- Execute this file to populate test database with sample data
-- ============================================================================

-- ============================================================================
-- CLEANUP: Remove existing test data
-- ============================================================================
-- Order matters due to foreign key constraints

DELETE FROM audit_log WHERE review_id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
DELETE FROM workflow_state WHERE review_id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
DELETE FROM screening_decisions WHERE review_id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
DELETE FROM search_executions WHERE review_id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
DELETE FROM documents WHERE review_id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
DELETE FROM reviews WHERE id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';

-- ============================================================================
-- FIXTURE 1: Sample Review Record
-- ============================================================================
-- A systematic review examining exercise interventions for depression
-- Includes complete PICO criteria for screening guidance

INSERT INTO reviews (
    id,
    title,
    description,
    research_question,
    population,
    intervention,
    comparison,
    outcome,
    study_design_criteria,
    exclusion_criteria,
    created_at,
    updated_at
) VALUES (
    'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
    'Exercise Interventions for Major Depressive Disorder: A Systematic Review',
    'This systematic review examines the effectiveness of structured exercise interventions in reducing depressive symptoms among adults diagnosed with major depressive disorder.',
    'Does structured exercise reduce depressive symptoms in adults with major depressive disorder compared to usual care or control conditions?',
    -- Population: Adults 18+ with diagnosed MDD
    'Adults aged 18 years or older with a primary diagnosis of major depressive disorder (MDD) confirmed by clinical interview or validated diagnostic criteria (DSM-5, ICD-10). Includes both inpatient and outpatient settings.',
    -- Intervention: Structured exercise programs
    'Structured exercise interventions including aerobic exercise (running, cycling, swimming), resistance training, or combined programs. Minimum duration of 4 weeks, with at least 2 sessions per week. Includes supervised and partially supervised programs.',
    -- Comparison: Control conditions
    'Usual care, waitlist control, attention control, or non-exercise active comparators (e.g., relaxation, health education). Pharmaceutical interventions are acceptable as co-interventions if balanced across groups.',
    -- Outcome: Depression symptom measures
    'Primary outcome: Change in depression symptom severity measured by validated scales (Beck Depression Inventory-II, Hamilton Depression Rating Scale, Patient Health Questionnaire-9, Montgomery-Åsberg Depression Rating Scale). Secondary outcomes: quality of life, adherence rates, adverse events.',
    -- Study Design Criteria
    'Randomized controlled trials (RCTs) only. Minimum sample size of 20 participants (10 per arm). Published in peer-reviewed journals. No language restrictions if translation available.',
    -- Exclusion Criteria
    'Studies focused on bipolar disorder, postpartum depression, or depression secondary to medical conditions. Exercise as part of multimodal interventions where effects cannot be isolated. Conference abstracts, dissertations without peer review, case studies, qualitative studies.',
    '2025-01-15 10:00:00',
    '2025-01-15 10:00:00'
);

-- ============================================================================
-- FIXTURE 2: Sample Documents
-- ============================================================================
-- 5 documents with varying relevance for screening practice
-- Mix of clear includes, clear excludes, and borderline cases

-- Document 1: CLEAR INCLUDE
-- RCT of aerobic exercise for MDD in adults
INSERT INTO documents (
    id,
    review_id,
    title,
    authors,
    publication_year,
    abstract,
    doi,
    source_database,
    import_date,
    created_at,
    updated_at
) VALUES (
    '11111111-1111-1111-1111-111111111111',
    'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
    'Aerobic Exercise Training for Major Depressive Disorder: A Randomized Controlled Trial',
    'Smith J, Johnson M, Williams K, Brown L, Davis R',
    2023,
    'BACKGROUND: Major depressive disorder (MDD) is a leading cause of disability worldwide. Exercise may offer benefits beyond traditional treatments. METHODS: We conducted a 12-week randomized controlled trial comparing supervised aerobic exercise (n=45) to waitlist control (n=43) in adults with MDD diagnosed by DSM-5 criteria. Exercise consisted of 45-minute cycling sessions 3 times weekly at 60-75% maximum heart rate. Primary outcome was Hamilton Depression Rating Scale (HDRS) at 12 weeks. RESULTS: Exercise group showed significant reduction in HDRS scores (mean difference -8.3 points, 95% CI -11.2 to -5.4, p<0.001) compared to control. Remission rate was 42% vs 18% (p=0.008). CONCLUSIONS: Supervised aerobic exercise significantly reduced depressive symptoms in adults with MDD.',
    '10.1001/example.2023.001',
    'PubMed',
    '2025-01-18 14:23:45',
    '2025-01-18 14:23:45',
    '2025-01-18 14:23:45'
);

-- Document 2: CLEAR EXCLUDE - Wrong population (adolescents)
INSERT INTO documents (
    id,
    review_id,
    title,
    authors,
    publication_year,
    abstract,
    doi,
    source_database,
    import_date,
    created_at,
    updated_at
) VALUES (
    '22222222-2222-2222-2222-222222222222',
    'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
    'School-Based Exercise Program for Adolescent Depression',
    'Garcia M, Rodriguez A, Martinez L',
    2022,
    'OBJECTIVE: To evaluate a school-based exercise program for adolescents with depressive symptoms. METHODS: Adolescents aged 13-17 years (n=120) with elevated Patient Health Questionnaire-9 scores were randomized to exercise or usual care. Exercise consisted of team sports 4 times weekly for 8 weeks. RESULTS: Significant improvement in PHQ-9 scores in exercise group. CONCLUSIONS: School-based exercise programs may benefit adolescents with depression.',
    '10.1001/example.2022.002',
    'PubMed',
    '2025-01-18 14:25:12',
    '2025-01-18 14:25:12',
    '2025-01-18 14:25:12'
);

-- Document 3: CLEAR EXCLUDE - Wrong study design (observational)
INSERT INTO documents (
    id,
    review_id,
    title,
    authors,
    publication_year,
    abstract,
    doi,
    source_database,
    import_date,
    created_at,
    updated_at
) VALUES (
    '33333333-3333-3333-3333-333333333333',
    'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
    'Association Between Physical Activity Levels and Depression: A Cross-Sectional Study',
    'Chen W, Liu Y, Wang X, Zhang H',
    2023,
    'BACKGROUND: Physical activity may be associated with lower depression risk. METHODS: Cross-sectional analysis of 1,842 adults from community health screening. Physical activity assessed by questionnaire, depression by Beck Depression Inventory-II. RESULTS: Higher physical activity levels inversely associated with depression scores (β=-0.34, p<0.001) after adjusting for age, sex, and socioeconomic status. CONCLUSIONS: Physical activity shows negative association with depression in community sample.',
    '10.1001/example.2023.003',
    'Web of Science',
    '2025-01-18 14:27:33',
    '2025-01-18 14:27:33',
    '2025-01-18 14:27:33'
);

-- Document 4: BORDERLINE - Multimodal intervention
-- Exercise combined with CBT, unclear if effects can be isolated
INSERT INTO documents (
    id,
    review_id,
    title,
    authors,
    publication_year,
    abstract,
    doi,
    source_database,
    import_date,
    created_at,
    updated_at
) VALUES (
    '44444444-4444-4444-4444-444444444444',
    'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
    'Combined Exercise and Cognitive Behavioral Therapy for Treatment-Resistant Depression',
    'Anderson P, Thompson R, Miller S',
    2023,
    'INTRODUCTION: Treatment-resistant depression (TRD) requires novel approaches. METHODS: RCT of 78 adults with TRD randomized to: (1) CBT alone, (2) exercise alone, or (3) combined CBT+exercise. Exercise was supervised resistance training 3x/week for 16 weeks. CBT was weekly individual sessions. Primary outcome: Montgomery-Åsberg Depression Rating Scale. RESULTS: All groups improved, with combined treatment showing greatest effect (MADRS reduction: combined -18.2, exercise -12.1, CBT -11.8). CONCLUSIONS: Combined treatment appears most effective for TRD.',
    '10.1001/example.2023.004',
    'PubMed',
    '2025-01-18 14:29:15',
    '2025-01-18 14:29:15',
    '2025-01-18 14:29:15'
);

-- Document 5: LIKELY INCLUDE
-- RCT of resistance training for MDD in older adults
INSERT INTO documents (
    id,
    review_id,
    title,
    authors,
    publication_year,
    abstract,
    doi,
    source_database,
    import_date,
    created_at,
    updated_at
) VALUES (
    '55555555-5555-5555-5555-555555555555',
    'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
    'Progressive Resistance Training for Late-Life Depression: A Pilot Randomized Trial',
    'Wilson T, Davis K, Moore J, Taylor B',
    2022,
    'BACKGROUND: Depression in older adults often goes undertreated. Resistance training may provide alternative. METHODS: Pilot RCT of 32 community-dwelling adults aged 60+ with major depressive disorder (DSM-5). Participants randomized to supervised progressive resistance training (n=16) or health education control (n=16) for 10 weeks. Resistance training involved 8 exercises, 2 sets of 10-12 repetitions, 2x/week. Primary outcome: Beck Depression Inventory-II. RESULTS: Significant group×time interaction (p=0.021). BDI-II decreased 11.2 points in exercise vs 3.1 points in control. CONCLUSIONS: Resistance training shows promise for late-life depression.',
    '10.1001/example.2022.005',
    'PsycINFO',
    '2025-01-18 14:31:47',
    '2025-01-18 14:31:47',
    '2025-01-18 14:31:47'
);

-- ============================================================================
-- FIXTURE 3: Sample Search Execution
-- ============================================================================
-- PubMed search that retrieved the documents above

INSERT INTO search_executions (
    id,
    review_id,
    database_name,
    search_strategy,
    execution_date,
    results_count,
    notes,
    created_at,
    updated_at
) VALUES (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
    'PubMed',
    '("depressive disorder, major"[MeSH] OR "depression"[MeSH] OR "major depressive disorder"[tiab]) AND ("exercise"[MeSH] OR "exercise therapy"[MeSH] OR "physical activity"[tiab] OR "aerobic exercise"[tiab] OR "resistance training"[tiab]) AND ("randomized controlled trial"[pt] OR "controlled clinical trial"[pt] OR "randomized"[tiab]) AND 2020:2025[dp]',
    '2025-01-18 14:00:00',
    247,
    'Initial PubMed search for 2020-2025. Yielded 247 results. Applied additional filters for English language and full-text availability in Covidence.',
    '2025-01-18 14:00:00',
    '2025-01-18 14:00:00'
);

-- ============================================================================
-- FIXTURE 4: Sample Screening Decisions
-- ============================================================================
-- 3 decisions demonstrating different screening outcomes

-- Decision 1: INCLUDE decision for clear RCT
INSERT INTO screening_decisions (
    id,
    review_id,
    document_id,
    decision,
    rationale,
    screened_by,
    screened_at,
    confidence_level,
    created_at,
    updated_at
) VALUES (
    'cccccccc-1111-1111-1111-111111111111',
    'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
    '11111111-1111-1111-1111-111111111111',
    'include',
    'INCLUDE - Meets all criteria: (1) RCT design, (2) Adults 18+ with DSM-5 confirmed MDD, (3) Structured aerobic exercise intervention >4 weeks, (4) Waitlist control, (5) Validated outcome measure (HDRS). Study is directly relevant to research question.',
    'reviewer1@university.edu',
    '2025-01-20 09:15:23',
    'high',
    '2025-01-20 09:15:23',
    '2025-01-20 09:15:23'
);

-- Decision 2: EXCLUDE decision for adolescent study
INSERT INTO screening_decisions (
    id,
    review_id,
    document_id,
    decision,
    rationale,
    screened_by,
    screened_at,
    confidence_level,
    created_at,
    updated_at
) VALUES (
    'cccccccc-2222-2222-2222-222222222222',
    'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
    '22222222-2222-2222-2222-222222222222',
    'exclude',
    'EXCLUDE - Wrong population. Study focuses on adolescents aged 13-17, but our review requires adults 18+. Although study design (RCT) and intervention type (exercise) are appropriate, age criterion not met.',
    'reviewer1@university.edu',
    '2025-01-20 09:22:41',
    'high',
    '2025-01-20 09:22:41',
    '2025-01-20 09:22:41'
);

-- Decision 3: UNCERTAIN decision for multimodal intervention
INSERT INTO screening_decisions (
    id,
    review_id,
    document_id,
    decision,
    rationale,
    screened_by,
    screened_at,
    confidence_level,
    created_at,
    updated_at
) VALUES (
    'cccccccc-4444-4444-4444-444444444444',
    'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
    '44444444-4444-4444-4444-444444444444',
    'uncertain',
    'UNCERTAIN - Study has 3-arm design including exercise-only arm, which may meet criteria. However, primary analysis focuses on combined CBT+exercise. Need to review full text to determine if exercise-only arm results are reported separately with sufficient detail. Population (TRD) may be acceptable as subset of MDD.',
    'reviewer2@university.edu',
    '2025-01-20 10:33:17',
    'medium',
    '2025-01-20 10:33:17',
    '2025-01-20 10:33:17'
);

-- ============================================================================
-- FIXTURE 5: Sample Workflow State Checkpoint
-- ============================================================================
-- Checkpoint after completing title/abstract screening for first batch

INSERT INTO workflow_state (
    id,
    review_id,
    current_stage,
    stage_status,
    checkpoint_data,
    created_at,
    updated_at
) VALUES (
    'dddddddd-dddd-dddd-dddd-dddddddddddd',
    'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
    'title_abstract_screening',
    'in_progress',
    '{
        "total_documents": 247,
        "screened_count": 5,
        "include_count": 1,
        "exclude_count": 1,
        "uncertain_count": 1,
        "remaining_count": 242,
        "dual_screening_enabled": true,
        "conflict_resolution_required": 0,
        "current_batch": 1,
        "total_batches": 50,
        "started_at": "2025-01-20T09:00:00Z",
        "estimated_completion": "2025-02-15T17:00:00Z",
        "reviewers_assigned": ["reviewer1@university.edu", "reviewer2@university.edu"],
        "screening_rate_per_hour": 12
    }',
    '2025-01-20 11:00:00',
    '2025-01-20 11:00:00'
);

-- ============================================================================
-- FIXTURE 6: Sample Audit Log Entries
-- ============================================================================
-- Audit trail showing review workflow progression

-- Entry 1: Review creation
INSERT INTO audit_log (
    id,
    review_id,
    action,
    actor,
    timestamp,
    details,
    created_at
) VALUES (
    'eeeeeeee-1111-1111-1111-111111111111',
    'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
    'review_created',
    'admin@university.edu',
    '2025-01-15 10:00:00',
    '{
        "review_title": "Exercise Interventions for Major Depressive Disorder: A Systematic Review",
        "protocol_registered": "PROSPERO CRD42025123456",
        "team_members": ["reviewer1@university.edu", "reviewer2@university.edu", "senior_author@university.edu"]
    }',
    '2025-01-15 10:00:00'
);

-- Entry 2: Search execution
INSERT INTO audit_log (
    id,
    review_id,
    action,
    actor,
    timestamp,
    details,
    created_at
) VALUES (
    'eeeeeeee-2222-2222-2222-222222222222',
    'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
    'search_executed',
    'librarian@university.edu',
    '2025-01-18 14:00:00',
    '{
        "database": "PubMed",
        "search_strategy_version": "1.0",
        "results_count": 247,
        "date_range": "2020-2025",
        "peer_reviewed": true
    }',
    '2025-01-18 14:00:00'
);

-- Entry 3: Document import
INSERT INTO audit_log (
    id,
    review_id,
    action,
    actor,
    timestamp,
    details,
    created_at
) VALUES (
    'eeeeeeee-3333-3333-3333-333333333333',
    'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
    'documents_imported',
    'reviewer1@university.edu',
    '2025-01-18 15:30:00',
    '{
        "source": "PubMed RIS export",
        "documents_imported": 247,
        "duplicates_removed": 18,
        "import_method": "RIS file upload"
    }',
    '2025-01-18 15:30:00'
);

-- Entry 4: Screening started
INSERT INTO audit_log (
    id,
    review_id,
    action,
    actor,
    timestamp,
    details,
    created_at
) VALUES (
    'eeeeeeee-4444-4444-4444-444444444444',
    'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
    'screening_started',
    'reviewer1@university.edu',
    '2025-01-20 09:00:00',
    '{
        "stage": "title_abstract_screening",
        "screening_mode": "dual_independent",
        "randomization_enabled": true,
        "conflict_threshold": 0.2
    }',
    '2025-01-20 09:00:00'
);

-- Entry 5: First screening decision
INSERT INTO audit_log (
    id,
    review_id,
    action,
    actor,
    timestamp,
    details,
    created_at
) VALUES (
    'eeeeeeee-5555-5555-5555-555555555555',
    'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
    'document_screened',
    'reviewer1@university.edu',
    '2025-01-20 09:15:23',
    '{
        "document_id": "11111111-1111-1111-1111-111111111111",
        "decision": "include",
        "confidence": "high",
        "screening_time_seconds": 127,
        "stage": "title_abstract_screening"
    }',
    '2025-01-20 09:15:23'
);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- Uncomment these to verify fixture data after import

-- SELECT COUNT(*) as review_count FROM reviews WHERE id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
-- SELECT COUNT(*) as document_count FROM documents WHERE review_id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
-- SELECT COUNT(*) as decision_count FROM screening_decisions WHERE review_id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
-- SELECT COUNT(*) as search_count FROM search_executions WHERE review_id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
-- SELECT COUNT(*) as workflow_count FROM workflow_state WHERE review_id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
-- SELECT COUNT(*) as audit_count FROM audit_log WHERE review_id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';

-- ============================================================================
-- END OF FIXTURES
-- ============================================================================
