select am, pm, sum(count), sum(signed_sum), sum(signed_sum)/sum(count) as avg from (select name, am, pm, count, case when name='Opal' then -sum else sum end as signed_sum from peak_stats) as foo group by am, pm;

select sum(count), sum(signed_sum), sum(signed_sum)/sum(count) as avg from (select name, count, case when name='Opal' then -sum else sum end as signed_sum from opal where mode='train') as foo;
