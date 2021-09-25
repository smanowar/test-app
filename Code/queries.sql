-- Merged Dataframe
SELECT q_id,
	   q_title,
	   q_body,
	   accepted_answer_id,
	   q_creation_date,
	   q_score,
	   q_tags,
	   q_view_count,
	   q_score_tier,
       q_title_char_count,
	   q_title_word_count,
	   q_title_char_count_bin,
       q_title_word_count_bin, 
	   q_view_count_bin, 
	   q_body_word_count,
       q_body_len_bin, 
	   q_tags_count
INTO questions_with_accepted_answers
FROM posts_questions as posts_q
LEFT JOIN posts_answers as posts_a ON posts_q.accepted_answer_id = posts_a.a_id;

-- Duration Dataframe
SELECT q.q_id,
	   q.accepted_answer_id,
	   q.q_creation_date,
	   an.a_id,
	   an.a_creation_date
INTO duration
FROM posts_questions as q
INNER JOIN posts_answers as an
ON (q.accepted_answer_id = an.a_id)

-- ML Dataframe
SELECT q.q_id,
	   q.q_title,
	   q.q_body,
	   q.accepted_answer_id,
	   q.q_creation_date,
	   q.q_score,
	   q.q_tags,
	   q.q_view_count,
	   q.q_score_tier,
	   q.q_title_char_count,
	   q.q_title_word_count,
	   q.q_title_char_count_bin,
	   q.q_title_word_count_bin,
	   q.q_view_count_bin,
	   q.q_body_word_count,
	   q.q_body_len_bin,
	   q.q_tags_count,
	   d.a_creation_date,
	   d.q_day,
	   d.q_hour,
	   d.accepted_answer_duration
INTO ml_input
FROM posts_questions as q
JOIN duration as d
ON (q.q_id = d.q_id);