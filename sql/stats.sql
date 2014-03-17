select * from opal order by count desc;
select name, sum(count), sum(sum) from opal group by name;
select * from peak_stats order by count desc;
