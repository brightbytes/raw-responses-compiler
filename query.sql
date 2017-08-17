SELECT   q.congo_survey_id AS id,
         o.name AS organization_name,
         (CASE WHEN st.name LIKE '%Teacher%' THEN 'Teacher & Admin'
               WHEN st.name LIKE '%Lower%'   THEN 'Lower Student'
               WHEN st.name LIKE '%Middle%'  THEN 'Middle Student'
               WHEN st.name LIKE '%High%'    THEN 'High Student'
               WHEN st.name LIKE '%Parent%'  THEN 'Parent'
               ELSE NULL
               END) AS group_name
FROM     organizations AS o
JOIN     questionnaires AS q
         ON q.organization_id = o.id
JOIN     questionnaire_survey_templates AS qst
         ON qst.questionnaire_id = q.id
JOIN     survey_templates AS st
         ON st.id = qst.survey_template_id
JOIN     (SELECT   qr.questionnaire_id
          FROM     questionnaire_responses AS qr
          WHERE    (qr.organization_id IN (SELECT r.child_id
                                          FROM   relationships AS r
                                          WHERE  r.parent_id = /* PARENT_ORGANIZATION_ID */)
                    OR qr.organization_id = /* PARENT_ORGANIZATION_ID */)
          /* DATE_FILTER_PLACEHOLDER */
          GROUP BY qr.raw_data::JSON->>'campaign_id', qr.questionnaire_id, qr.organization_id
          HAVING   COUNT(qr.organization_id) > 0) AS no_responses_filter
         ON no_responses_filter.questionnaire_id = q.id
WHERE    (o.id IN (SELECT r.child_id
                   FROM   relationships AS r
                   WHERE  r.parent_id = /* PARENT_ORGANIZATION_ID */)
          OR o.id = /* PARENT_ORGANIZATION_ID */)
AND      o.entity_type = 'School'
ORDER BY o.name,
         (CASE WHEN st.name LIKE '%Teacher%' THEN 1
               WHEN st.name LIKE '%Lower%'   THEN 2
               WHEN st.name LIKE '%Middle%'  THEN 3
               WHEN st.name LIKE '%High%'    THEN 4
               WHEN st.name LIKE '%Parent%'  THEN 5
               ELSE 6
               END);
