select sr.employee_number,
       sr.worker_id,
       sr.formatted_name,
       'Job Function is null for some godforesaken reason' as text
from `kipptaf_people.int_people__staff_roster` as sr
where  sr.assignment_status != "Terminated" 
  and sr.job_function is null

union all

select sr.employee_number,
       sr.worker_id,
       sr.formatted_name,
       concat(sr.job_title,' does not match job function: ',sr.job_function) as text

from `kipptaf_people.int_people__staff_roster` as sr
where sr.assignment_status != "Terminated" and (
(sr.job_title = 'Academic Operations Manager' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Assistant School Leader, SPED' AND job_function != 'Assistant School Leaders') OR
(sr.job_title = 'Speech Language Pathologist' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Student Support Advocate' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Summer Program Teacher' AND job_function != 'Teacher') OR
(sr.job_title = 'Supervisor' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'System Administrator' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Systems Analyst' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Systems Engineer' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Teacher' AND job_function != 'Teacher') OR
(sr.job_title = 'Teacher in Residence' AND job_function != 'Teacher in Residence') OR
(sr.job_title = 'Teacher ESL' AND job_function != 'Teacher') OR
(sr.job_title = 'Assistant Superintendent' AND job_function != 'EDs, HOSs, MDOs') OR
(sr.job_title = 'Team and Family Couselor' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Americorps Resident' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Praxis Tutor' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Operations- Aide' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Head of Schools in Residence' AND job_function != 'EDs, HOSs, MDOs') OR
(sr.job_title = 'Managing Director in Residence' AND job_function != 'EDs, HOSs, MDOs') OR
(sr.job_title = 'Operations Assistant' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Managing Director of Growth' AND job_function != 'KTAF or Regional Managing Director') OR
(sr.job_title = 'Summer Credit Recovery Teacher' AND job_function != 'Teacher') OR
(sr.job_title = 'Summer School Teacher' AND job_function != 'Teacher') OR
(sr.job_title = 'Associate' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Mental Health Counselor' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Academic Interventionist' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Substitute Teacher' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Summer Program Paraprofessional' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Summer Program Social Worker' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Summer Program Manager' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Engineer' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Summer Program Speech Language Pathologist' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Summer Program  Occupational Therapist' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Porter' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Associate Director' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Summer Program Student Support Advocate' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Chief People Officer' AND job_function != 'Chief Level') OR
(sr.job_title = 'Registered Nurse' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'School Facilities Manager 1' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'School Facilities Manager 2' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Campus Facilities Manager' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Regional Facilities Manager' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Teacher in Residence ESL' AND job_function != 'Teacher in Residence') OR
(sr.job_title = 'Teacher-CertChange' AND job_function != 'Teacher') OR
(sr.job_title = 'Deputy Chief' AND job_function != 'EDs, HOSs, MDOs') OR
(sr.job_title = 'Associate Director of School Operations' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Accountant' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Managing Director of Teaching & Learning' AND job_function != 'KTAF or Regional Managing Director') OR
(sr.job_title = 'Teacher Aide' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Summer Nurse' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Operations Coordinator' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Deputy Head of Schools' AND job_function != 'EDs, HOSs, MDOs') OR
(sr.job_title = 'Chief College and Career Officer' AND job_function != 'Chief Level') OR
(sr.job_title = 'Generalist' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Licensed Security Officer' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Associate Temporary' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Aide - Non-Instructional - Level II' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Assistant School Leader, School Culture' AND job_function != 'Assistant School Leaders') OR
(sr.job_title = 'Chief Development Officer' AND job_function != 'Chief Level') OR
(sr.job_title = 'ESE Teacher' AND job_function != 'Teacher') OR
(sr.job_title = 'Senior Specialist' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Senior Manager' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Saturday School Teacher' AND job_function != 'Teacher') OR
(sr.job_title = 'Saturday School Paraprofessional' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Fellow' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Co-President' AND job_function != 'Chief Level') OR
(sr.job_title = 'Behavior Analyst' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'School Facilities Specialist' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Campus Facilities Specialist' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Chief' AND job_function != 'Chief Level') OR
(sr.job_title = 'Crossing Guard' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Instructor in Residence' AND job_function != 'Teacher in Residence') OR
(sr.job_title = 'Junior Accountant' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Instructor in Residence' AND job_function != 'Teacher in Residence') OR
(sr.job_title = 'Instructional Aide' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'School Facilities Specialist 1' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Behavior Specialist' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'School Facilities Specialist 2' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Campus Facilities Specialist 1' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Campus Facilities Specialist 2' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'ESE Program Specialist' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Bus Driver' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Transportation Manager' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Director of Orchestra and Music' AND job_function != 'Teacher') OR
(sr.job_title = 'Registrar' AND job_function != '') OR
(sr.job_title = 'Canvasser' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Chief Academic Officer' AND job_function != 'Chief Level') OR
(sr.job_title = 'Achievement Director' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Chief Equity Strategist' AND job_function != 'Chief Level') OR
(sr.job_title = 'Chief Executive Officer' AND job_function != 'Chief Level') OR
(sr.job_title = 'Chief External Officer' AND job_function != 'Chief Level') OR
(sr.job_title = 'Chief Financial Officer' AND job_function != 'Chief Level') OR
(sr.job_title = 'Chief of Staff' AND job_function != 'Chief Level') OR
(sr.job_title = 'Chief Operating Officer' AND job_function != 'Chief Level') OR
(sr.job_title = 'College Persistence Counselor' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'College Placement Counselor' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'College to Career Manager' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Compliance Manager' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'After School Program Assignment' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Controller' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Coordinator' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Coordinator Part-Time' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Counselor' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Custodian' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Data and Operations Manager' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Dean' AND job_function != 'Deans') OR
(sr.job_title = 'Dean of Students' AND job_function != 'Deans') OR
(sr.job_title = 'Deputy Chief Officer' AND job_function != 'EDs, HOSs, MDOs') OR
(sr.job_title = 'Director' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'After School Program Director' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Director Campus Operations' AND job_function != 'DSOs') OR
(sr.job_title = 'Director Community Relations' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Director Deputy' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Director Elementary Literacy Curriculum' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Director Finance Special Projects' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Director Financial Planning & Analysis' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Director Foundation and Corporate Giving' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Director High School Literacy Curriculum' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Director Literacy Achievement' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Director Math Achievement' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Aide - Non-Instructional' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Director Middle School Literacy Curriculum' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Director of Accounting' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Dir of Enrollment and Community Engagement' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Director of New Teacher Development' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Director of Social Work' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Director Purchasing' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Director School Operations' AND job_function != 'DSOs') OR
(sr.job_title = 'Director Strategic Initiatives' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Director College and Career Placement' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Director College and Career Readiness' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Analyst' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Director College Persistence' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Director Employee Relations' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Executive Assistant' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Executive Director' AND job_function != 'EDs, HOSs, MDOs') OR
(sr.job_title = 'Extra-Curricular Assignment' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Fellow School Operations Director' AND job_function != 'DSOs') OR
(sr.job_title = 'Head of Schools' AND job_function != 'EDs, HOSs, MDOs') OR
(sr.job_title = 'Home Instructor' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Intern' AND job_function != 'Interns') OR
(sr.job_title = 'Learning Disabilities Teacher Consultant' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Assistant' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Learning Specialist' AND job_function != 'Teacher') OR
(sr.job_title = 'Learning Specialist Coordinator' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Manager' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Managing Director' AND job_function != 'KTAF or Regional Managing Director') OR
(sr.job_title = 'Managing Director of Operations' AND job_function != 'EDs, HOSs, MDOs') OR
(sr.job_title = 'Managing Director of School Operations' AND job_function != 'KTAF or Regional Managing Director') OR
(sr.job_title = 'Managing Director of Talent Acquisition' AND job_function != 'KTAF or Regional Managing Director') OR
(sr.job_title = 'Managing Director Accounting' AND job_function != 'KTAF or Regional Managing Director') OR
(sr.job_title = 'Licensed Practical Nurse' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Occupational Therapist' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Assistant Dean' AND job_function != 'Deans') OR
(sr.job_title = 'Office Manager' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Operations Associate' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Paraprofessional' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Payroll Accountant' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Purchasing Coordinator' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Receptionist' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Recruiter' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'School Based Advocate' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'School Leader' AND job_function != 'School Leader') OR
(sr.job_title = 'School Leader in Residence' AND job_function != 'School Leader') OR
(sr.job_title = 'Assistant School Leader' AND job_function != 'Assistant School Leaders') OR
(sr.job_title = 'School Operations Manager' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'School Psychologist' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Security' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Senior Accountant' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Senior Analyst' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Senior Custodian' AND job_function != 'ADSOs, Ops-SOMs, AOMs, & Receptionists') OR
(sr.job_title = 'Social Worker' AND job_function != 'School-based Non-Instructional Staff') OR
(sr.job_title = 'Special Counsel' AND job_function != 'KTAF or Regional Director') OR
(sr.job_title = 'Specialist' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Specialist Temporary' AND job_function != 'KTAF or Regional Staff') OR
(sr.job_title = 'Chief College and Career Officer' AND job_function != 'Chief Level')
)
