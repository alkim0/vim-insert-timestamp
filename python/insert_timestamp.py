import datetime

import parsedatetime

import tzlocal

cal = parsedatetime.Calendar()


DATE_FORMAT = '%Y-%m-%d %a'
TIME_FORMAT = '%H:%M'


class DT(object):
    """
    A datetime object that has just date or date and time.
    """
    def __init__(self, date, time):
        self._date = date
        self._time = time

    @property
    def has_time(self):
        return self._time is not None

    @property
    def date(self):
        return self._date

    @property
    def time(self):
        if not self.has_time:
            raise Exception('No time for {}'.format(self))
        return self._time

    def format(self):
        date = self._date.strftime(DATE_FORMAT)
        if self.has_time:
            time = self._time.strftime(TIME_FORMAT)
            return '<{} {}>'.format(date, time)
        else:
            return '<{}>'.format(date)

    def __lt__(self, other):
        if self.date < other.date:
            return True
        elif self.date > other.date:
            return False
        else:
            if self.has_time and other.has_time:
                return self.time < other.time
            elif not self.has_time and other.has_time:
                return True
            elif self.has_time and not other.has_time:
                return False
            else:
                return False


class DTR(object):
    """
    A DT range class.
    """
    def __init__(self, beg, end):
        self._beg = beg
        self._end = end

    def format(self):
        if self._beg.has_time and self._beg.date == self._end.date:
            beg_time = self._beg.time.strftime(TIME_FORMAT)
            end_time = self._end.time.strftime(TIME_FORMAT)
            date = self._beg.date.strftime(DATE_FORMAT)
            return '<{} {}-{}>'.format(date, beg_time, end_time)
        else:
            return '{}--{}'.format(self._beg.format(), self._end.format())


def parse(s):
    """
    Evaluates the so-far entered string and shows what it would parse as.

    Args:
        s: String to be parsed.

    Returns:
        Formatted string which would be output.
    """
    return _parse(s).format()

def _parse(s):
    if '-' not in s:
        # This is not a range, try to parse as singular DT
        st, status = cal.parse(s)

        if status == 0:
            # If the string parsed to either nothing just return today's date.
            dt = DT(datetime.date.today(), None)
        elif status == 1:
            # Only date was parsed, return that date.
            dt = DT(datetime.date(*st[:3]), None)
        else:
            # Both date and time were parsed.
            dt = DT(datetime.date(*st[:3]), datetime.time(*st[3:5]))

    else:
        # This is a range
        beg, end, status = cal.evalRanges(s)

        if status == 0:
            # Was not parsed correctly, try to split and run parse separately
            splitted = s.split('-')
            if len(splitted) != 2:
                # Does not have exaclty 2 parts, don't know what to do, so
                # return today's date.
                dt = DT(datetime.date.today(), None)
            else:
                beg, end = (_parse(x) for x in splitted)
                if beg == end:
                    dt = beg
                elif end < beg:
                    # For some reason, beg comes after end, which is clearly
                    # faulty, so return today's date.
                    dt = DT(datetime.date.today(), None)
                else:
                    dt = DTR(beg, end)
        elif status in (4, 5, 6):
            # Only the dates were parsed in the range.
            dt = DTR(DT(datetime.date(*beg[:3]), None),
                     DT(datetime.date(*end[:3]), None))
        else:
            # Both the time was parsed.
            dt = DTR(DT(datetime.date(*beg[:3]), datetime.time(*beg[3:5])),
                     DT(datetime.date(*end[:3]), datetime.time(*end[3:5])))

    return dt

def get_local_tz():
    return tzlocal.get_localzone().zone
