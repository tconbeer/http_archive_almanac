-- In general we want to avoid "SELECT *" but we'll make an exception here so disable
-- rile L044
select date('2020-08-01') as date, *  -- noqa: L044
from `lighthouse-infrastructure.third_party_web.2020_08_01`
