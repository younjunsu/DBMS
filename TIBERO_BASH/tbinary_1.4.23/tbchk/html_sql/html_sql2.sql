select 
        '</td></tr>'||chr(10)||
        '<tr><td colspan="3">7. File system check</td></tr>'||chr(10)||
        '<tr>'||chr(10)||'<td style="padding-left:10px">7.1 Home directory</td>'||chr(10)||'<td>Free - 20% 이상 유지</td><td></td></tr>'||chr(10)||
        '<tr>'||chr(10)||'<td style="padding-left:10px">7.2 Data file directory</td>'||chr(10)||'<td>Free - 20% 이상 유지</td><td></td></tr>'||chr(10)||
        '<tr>'||chr(10)||'<td style="padding-left:10px">7.3 Archive log Dest</td>'||chr(10)||'<td>Free - 20% 이상 유지</td><td></td></tr>'||chr(10)||
        '<tr><td colspan="3">8. Alert Log</td></tr>'||chr(10)||
        '<tr>'||chr(10)||'<td style="padding-left:10px">8.1 Call stack 발생 (tbsvr.out 파일) </td>'||chr(10)||'<td>발생 유무</td><td></td></tr>'
from dual;
