# 🚀 DBT MasterClass - Course Materials

> **Từ AWS Glue đến DBT Core** - Xây dựng Modern Data Pipeline với S3, PostgreSQL và Airflow

---

## 📚 Course Structure

### Quick Links
- **[📖 Course Index](index.html)** - Main navigation hub
- **[📋 Syllabus](COURSE_SYLLABUS.md)** - Detailed curriculum
- **[📝 Exercises](exercises/EXERCISES.md)** - Hands-on exercises
- **[💡 Solutions](exercises/SOLUTIONS.md)** - Complete solutions
- **[👨‍🏫 Instructor Guide](INSTRUCTOR_GUIDE.md)** - Teaching guidelines
- **[🚀 Deployment Guide](DEPLOYMENT_GUIDE.md)** - Production setup on EC2

### Interactive Slides (100% Complete!)
| Session | Topic | Link | Status |
|---------|-------|------|--------|
| 1 | Introduction to DBT | [session-01.html](slides/session-01.html) | ✅ Complete |
| 2 | First Models | [session-02.html](slides/session-02.html) | ✅ Complete |
| 3 | Intermediate Models | [session-03.html](slides/session-03.html) | ✅ Complete |
| 4 | Data Testing | [session-04.html](slides/session-04.html) | ✅ Complete |
| 5 | Documentation | [session-05.html](slides/session-05.html) | ✅ Complete |
| 6 | Macros | [session-06.html](slides/session-06.html) | ✅ Complete |
| 7-8 | Packages & Incremental | [session-07.html](slides/session-07.html) | ✅ Complete |
| 9-10 | Snapshots & Airflow | [session-09.html](slides/session-09.html) | ✅ Complete |
| 11-12 | Production & Near-Real-Time | [session-11.html](slides/session-11.html) | ✅ Complete |

---

## 🎯 Learning Objectives

After completing this course, students will be able to:

1. ✅ **Understand DBT Core** and its place in the Modern Data Stack
2. ✅ **Build staging, intermediate, and marts layers** following best practices
3. ✅ **Implement comprehensive testing** for data quality
4. ✅ **Generate and host documentation** for data discovery
5. ✅ **Write reusable macros** using Jinja templating
6. ✅ **Configure incremental models** for performance
7. ✅ **Implement snapshots** for slowly changing dimensions
8. ✅ **Orchestrate with Airflow** using DBT Operator
9. ✅ **Deploy to production** on EC2 with Docker
10. ✅ **Design near-real-time architectures** for future scaling

---

## 📁 Directory Structure

```
dbt-course/
├── index.html                 # Main course hub (Interactive!)
├── README.md                  # This file
├── COURSE_SYLLABUS.md         # Detailed 12-session curriculum
├── INSTRUCTOR_GUIDE.md        # Teaching guidelines & scripts
├── DEPLOYMENT_GUIDE.md        # Production setup on EC2
│
├── slides/                    # Interactive HTML slides
│   ├── session-01.html        # ✅ Introduction to DBT
│   ├── session-02.html        # ✅ First Models
│   ├── session-03.html        # ✅ Intermediate Models
│   └── session-04.html        # ✅ Data Testing
│
├── exercises/                 # Exercise materials
│   ├── EXERCISES.md           # All exercises (30+)
│   └── SOLUTIONS.md           # Complete solutions
│
├── datasets/                  # Sample data files
│   ├── sample_data.json       # Shopee/TikTok sample data
│   ├── exchange_rates.csv     # Currency exchange rates
│   └── status_mappings.csv    # Status mapping reference
│
├── scripts/                   # Utility scripts
│   ├── setup.sh               # Environment setup (Linux/Mac)
│   ├── setup.bat              # Environment setup (Windows)
│   └── deploy.sh              # Production deployment
│
└── templates/                 # Project templates
    └── dbt_project.yml        # DBT project configuration
```

---

## 🛠️ Prerequisites

### Technical Requirements
- Python 3.9+
- pip or conda
- Access to AWS (S3, EC2, RDS PostgreSQL)
- Docker Desktop (for containerization)
- Git (for version control)

### Knowledge Requirements
- SQL (intermediate level)
- Basic Python
- Familiar with AWS services (S3, EC2, RDS)
- Experience with data pipelines (preferred)

---

## 🚀 Quick Start

### For Students

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-org/dbt-course.git
   cd dbt-course
   ```

2. **Open the course index:**
   ```bash
   # On Mac/Linux
   open index.html

   # On Windows
   start index.html
   ```

3. **Start with Session 1:**
   - Click on "Buổi 01" in the session grid
   - Follow along with the interactive slides
   - Complete exercises after each session

4. **Setup your environment:**
   ```bash
   python -m venv dbt-venv
   source dbt-venv/bin/activate  # or dbt-venv\Scripts\activate on Windows
   pip install dbt-postgresql
   ```

### For Instructors

1. **Review the Instructor Guide:**
   - Read through `INSTRUCTOR_GUIDE.md`
   - Prepare talking points for each session
   - Practice live demos beforehand

2. **Setup demo environment:**
   - Ensure RDS PostgreSQL is accessible
   - Have sample data ready
   - Test all commands before class

3. **Prepare Q&A:**
   - Review common student issues
   - Have troubleshooting steps ready

---

## 📅 Schedule Options

### Option A: Intensive (2 weeks)
| Week | Day | Session |
|------|-----|---------|
| 1 | Mon | Session 1-2 |
| 1 | Tue | Session 3-4 |
| 1 | Wed | Session 5-6 |
| 1 | Thu | Session 7-8 |
| 1 | Fri | Session 9 |
| 2 | Mon | Session 10 |
| 2 | Tue | Session 11 |
| 2 | Wed | Session 12 + Final Presentations |

### Option B: Standard (4 weeks)
| Week | Session | Focus |
|------|---------|-------|
| 1 | 1-3 | DBT Fundamentals |
| 2 | 4-6 | Testing & Documentation |
| 3 | 7-9 | Advanced Patterns |
| 4 | 10-12 | Production Deployment |

### Option C: Extended (6 weeks)
| Week | Session | Additional Practice |
|------|---------|---------------------|
| 1 | 1-2 | Setup + Practice |
| 2 | 3-4 | Exercises + Review |
| 3 | 5-6 | Macro Workshop |
| 4 | 7-8 | Advanced Topics |
| 5 | 9-10 | Integration Lab |
| 6 | 11-12 | Final Project |

---

## 📊 Assessment

### Homework (40%)
- 10 assignments × 10 points each
- Best 8 scores count
- Submit via GitHub or Slack

### Quizzes (20%)
- Quick knowledge checks after each session
- Multiple choice + short answer
- Auto-graded via Google Forms

### Final Project (40%)
| Component | Points |
|-----------|--------|
| Pipeline completeness | 30 |
| Testing coverage | 20 |
| Documentation | 15 |
| Performance | 15 |
| Presentation | 20 |

### Certificate Levels
- **Completion:** 10/12 sessions + 8/10 homework
- **Proficiency:** Above + final project ≥ 70/100
- **Excellence:** Above + final project ≥ 90/100

---

## 🎓 Sample Projects

### Project Ideas

1. **E-commerce Analytics Pipeline**
   - Source: Shopee + TikTokShop APIs
   - Transform: DBT staging → intermediate → marts
   - Output: Daily sales, customer analytics, product performance

2. **Marketing Attribution**
   - Source: Facebook Ads, Google Ads, TikTok Ads
   - Transform: Multi-touch attribution modeling
   - Output: Campaign ROI, channel performance

3. **Inventory Management**
   - Source: Warehouse management system
   - Transform: Stock movement tracking, forecasting
   - Output: Reorder alerts, stock turnover analysis

### Project Timeline
| Week | Milestone |
|------|-----------|
| 1 | Project proposal + architecture design |
| 2-3 | Build data pipeline |
| 4 | Add testing and documentation |
| 5 | Deploy to production |
| 6 | Final presentation |

---

## 🔧 Tools & Resources

### DBT Ecosystem
- [DBT Core Documentation](https://docs.getdbt.com/)
- [DBT Packages](https://hub.getdbt.com/)
- [DBT Community](https://getdbt.com/community)

### Complementary Tools
- [Airflow Documentation](https://airflow.apache.org/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Documentation](https://docs.docker.com/)

### Learning Resources
- [DBT Guide](https://dbt-guide.com/)
- [Analytics Engineering Guide](https://analyticsengineering.guide/)
- [DataTalks.Club](https://datatalks.club/)

---

## 💡 Tips for Success

### For Students

1. **Practice daily:** Even 30 minutes of hands-on practice helps
2. **Ask questions:** No question is too basic
3. **Learn from errors:** Debugging is part of the learning process
4. **Build portfolio:** Document your projects on GitHub
5. **Join community:** Slack, Discord, Reddit DBT communities

### For Instructors

1. **Demo first:** Practice all demos before class
2. **Pace yourself:** Give students time to follow along
3. **Encourage questions:** Create safe learning environment
4. **Share war stories:** Real-world examples resonate
5. **Gather feedback:** Iterate and improve each cohort

---

## 📞 Support

### Contact
- **Instructor:** [Your Name]
- **Email:** [instructor@email.com]
- **Slack:** #dbt-masterclass

### Office Hours
- **Tuesday:** 2:00 PM - 4:00 PM
- **Thursday:** 2:00 PM - 4:00 PM
- **By appointment:** Available upon request

### Response Time
- Slack: Within 4 hours (business hours)
- Email: Within 24 hours
- Urgent: SMS/Call

---

## 🏆 Hall of Fame

### Top Students (Previous Cohorts)
- 🥇 [Student Name] - [Project Title]
- 🥈 [Student Name] - [Project Title]
- 🥉 [Student Name] - [Project Title]

### Success Stories
> "This course helped me transition from data analyst to analytics engineer. The hands-on projects were exactly what I needed!" - [Alumni Name]

> "Finally understand DBT deeply. The instructor's real-world examples made everything click." - [Alumni Name]

---

## 📝 License

This course material is licensed under [MIT License](LICENSE).

Feel free to use, modify, and share for educational purposes.

---

## 🙏 Acknowledgments

- DBT Labs for the amazing open-source tool
- Apache Airflow community
- All students who provided feedback
- [Contributors and supporters]

---

**Last updated:** March 2026
**Version:** 1.0.0
