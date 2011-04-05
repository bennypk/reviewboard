-- This view unifies line comments and general comments and normalizes them
-- so that it would be easy to group related comments together
create view review_issues as
select a.review_request_id as id,
concat(ifnull(a.base_reply_to_id,a.id),'_') as reply_to_id,
if(length(a.body_bottom)>0,a.body_bottom,a.body_top) as text,
a.timestamp
from
    reviews_review a
where length(body_bottom)+length(body_top) > 0
union all
select a.review_request_id as id, ifnull(c.reply_to_id,c.id) as reply_to_id,
c.text, c.timestamp
from reviews_review a, reviews_review_comments b, reviews_comment c
where a.id=b.review_id and b.comment_id=c.id
order by id,reply_to_id,timestamp desc;

-- This view specifies for each issue whether it has been resolved or not
create view review_issues_status as
select id,reply_to_id as issue_number,
substr(rtrim(replace(text,'\n',' ')),-3,3)='@@@' as resolved,
max(timestamp) from
review_issues
group by id,issue_number;

-- This view lists for each request how many issues exists and how many of them
-- have been resolved
-- (This should be the one to be used in the model)
create view reviews_issuessummary as
select id, id as review_request_id ,count(issue_number) as num_issues,
sum(resolved) as num_resolved
from review_issues_status
group by id;


