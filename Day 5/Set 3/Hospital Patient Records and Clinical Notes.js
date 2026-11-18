use("HospitalClinicalDB");

db.clinical_notes.drop();

db.createCollection("clinical_notes", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["visitId", "patientId", "doctorId", "noteDate", "diagnosis", "noteType"],
      properties: {
        visitId:   { bsonType: "number", minimum: 1 },
        patientId: { bsonType: "number", minimum: 1 },
        doctorId:  { bsonType: "number", minimum: 1 },
        noteDate:  { bsonType: "date" },
        diagnosis: { bsonType: "string", minLength: 1, maxLength: 500 },
        noteType:  { enum: ["CONSULTATION", "SPECIALIST_ASSESSMENT"] },
        vitals: {
          bsonType: "object",
          properties: {
            bloodPressure: {
              bsonType: "object",
              required: ["systolic", "diastolic"],
              properties: {
                systolic:  { bsonType: "number", minimum: 40, maximum: 300 },
                diastolic: { bsonType: "number", minimum: 20, maximum: 200 }
              }
            },
            heartRate:    { bsonType: "number", minimum: 20, maximum: 250 },
            temperatureC: { bsonType: "number", minimum: 30, maximum: 45 }
          }
        },
        symptoms: {
          bsonType: "array",
          items: { bsonType: "string" }
        },
        prescription: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["drug"],
            properties: {
              drug:      { bsonType: "string" },
              dose:      { bsonType: "string" },
              frequency: { bsonType: "string" }
            }
          }
        },
        assessment: {
          bsonType: "object",
          required: ["area", "findings"],
          properties: {
            area:      { bsonType: "string" },
            painScore: { bsonType: "number", minimum: 0, maximum: 10 },
            findings:  { bsonType: "string" }
          }
        },
        testsOrdered: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["test", "status"],
            properties: {
              test:   { bsonType: "string" },
              status: { enum: ["Advised", "Scheduled", "Pending", "Completed"] }
            }
          }
        }
      },
      oneOf: [
        {
          properties: { noteType: { enum: ["CONSULTATION"] } },
          required: ["vitals", "symptoms", "prescription"]
        },
        {
          properties: { noteType: { enum: ["SPECIALIST_ASSESSMENT"] } },
          required: ["assessment"]
        }
      ]
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

db.clinical_notes.createIndex({ diagnosis: 1 });
db.clinical_notes.createIndex({ patientId: 1, noteDate: -1 });

db.clinical_notes.insertMany([
  {
    visitId: 1, patientId: 1, doctorId: 1,
    noteDate: ISODate("2026-10-03T04:30:00Z"),
    diagnosis: "Hypertension",
    noteType: "CONSULTATION",
    vitals: { bloodPressure: { systolic: 150, diastolic: 95 }, heartRate: 82, temperatureC: 36.8 },
    symptoms: ["headache", "dizziness"],
    prescription: [{ drug: "Amlodipine", dose: "5mg", frequency: "Once daily" }],
    followUpDays: 14
  },
  {
    visitId: 4, patientId: 4, doctorId: 1,
    noteDate: ISODate("2026-10-15T05:15:00Z"),
    diagnosis: "Chest discomfort",
    noteType: "CONSULTATION",
    vitals: { bloodPressure: { systolic: 130, diastolic: 85 }, heartRate: 96, temperatureC: 36.9 },
    symptoms: ["chest tightness", "shortness of breath"],
    prescription: [],
    advice: "ECG requested for evaluation",
    followUpDays: 7
  },
  {
    visitId: 6, patientId: 6, doctorId: 4,
    noteDate: ISODate("2026-11-05T06:00:00Z"),
    diagnosis: "Viral fever",
    noteType: "CONSULTATION",
    vitals: { bloodPressure: { systolic: 110, diastolic: 70 }, heartRate: 100, temperatureC: 38.6 },
    symptoms: ["fever", "body ache"],
    prescription: [{ drug: "Paracetamol", dose: "500mg", frequency: "As advised" }],
    followUpDays: 3
  },
  {
    visitId: 9, patientId: 9, doctorId: 6,
    noteDate: ISODate("2026-11-12T08:45:00Z"),
    diagnosis: "High blood pressure",
    noteType: "CONSULTATION",
    vitals: { bloodPressure: { systolic: 160, diastolic: 100 }, heartRate: 88, temperatureC: 36.7 },
    symptoms: ["headache"],
    prescription: [{ drug: "Medication reviewed", frequency: "Continue current" }],
    followUpDays: 10
  },
  {
    visitId: 2, patientId: 2, doctorId: 2,
    noteDate: ISODate("2026-10-07T05:00:00Z"),
    diagnosis: "Migraine",
    noteType: "SPECIALIST_ASSESSMENT",
    assessment: { area: "Head", painScore: 7, findings: "Recurring headaches" },
    testsOrdered: [{ test: "MRI brain", status: "Advised" }]
  },
  {
    visitId: 3, patientId: 3, doctorId: 3,
    noteDate: ISODate("2026-10-12T07:20:00Z"),
    diagnosis: "Knee pain",
    noteType: "SPECIALIST_ASSESSMENT",
    assessment: { area: "Right knee", painScore: 6, findings: "Pain increases while walking" },
    testsOrdered: [{ test: "X-ray knee", status: "Pending" }]
  },
  {
    visitId: 5, patientId: 5, doctorId: 3,
    noteDate: ISODate("2026-11-02T04:10:00Z"),
    diagnosis: "Back pain",
    noteType: "SPECIALIST_ASSESSMENT",
    assessment: { area: "Lower back", painScore: 5, findings: "Posture and mobility assessed" },
    referral: { to: "Physiotherapy", reason: "Mobility improvement" }
  },
  {
    visitId: 7, patientId: 7, doctorId: 5,
    noteDate: ISODate("2026-11-08T09:30:00Z"),
    diagnosis: "Skin allergy",
    noteType: "SPECIALIST_ASSESSMENT",
    assessment: { area: "Both arms", painScore: 2, findings: "Rash observed on both arms" },
    testsOrdered: [{ test: "Allergy patch test", status: "Scheduled" }],
    attachments: [{ type: "photo", fileName: "rash_both_arms.jpg" }]
  }
]);

print("Documents inserted: " + db.clinical_notes.countDocuments());

try {
  db.clinical_notes.insertOne({
    visitId: 11, patientId: 1, doctorId: 1,
    noteDate: ISODate("2026-11-15T05:00:00Z"),
    diagnosis: "Hypertension",
    noteType: "CONSULTATION"
  });
  print("Invalid document was inserted");
} catch (e) {
  print("Invalid document rejected by validation");
}

try {
  db.clinical_notes.insertOne({
    visitId: 12, patientId: 3, doctorId: 3,
    noteDate: ISODate("2026-11-15T05:00:00Z"),
    diagnosis: "Knee pain",
    noteType: "SPECIALIST_ASSESSMENT",
    assessment: { area: "Left knee", painScore: 15, findings: "Swelling" }
  });
  print("Invalid document was inserted");
} catch (e) {
  print("Out-of-range pain score rejected by validation");
}

print("\n--- Notes with diagnosis 'Hypertension' ---");
db.clinical_notes
  .find({ diagnosis: "Hypertension" }, { _id: 0 })
  .forEach(doc => printjson(doc));

print("\n--- Notes with diagnosis containing 'blood pressure' (case-insensitive) ---");
db.clinical_notes
  .find({ diagnosis: /blood pressure/i }, { _id: 0, visitId: 1, patientId: 1, diagnosis: 1, vitals: 1 })
  .forEach(doc => printjson(doc));

print("\n--- Diagnosis in a list, newest first ---");
db.clinical_notes
  .find({ diagnosis: { $in: ["Knee pain", "Back pain"] } },
        { _id: 0, visitId: 1, diagnosis: 1, noteType: 1, assessment: 1 })
  .sort({ noteDate: -1 })
  .forEach(doc => printjson(doc));

print("\n--- Specialist assessments with pain score of 5 or more ---");
db.clinical_notes
  .find({ noteType: "SPECIALIST_ASSESSMENT", "assessment.painScore": { $gte: 5 } },
        { _id: 0, visitId: 1, diagnosis: 1, "assessment.painScore": 1 })
  .forEach(doc => printjson(doc));

print("\n--- Notes per diagnosis ---");
db.clinical_notes.aggregate([
  { $group: { _id: "$diagnosis", totalNotes: { $sum: 1 } } },
  { $sort: { _id: 1 } }
]).forEach(doc => printjson(doc));

print("\n--- Notes per note type ---");
db.clinical_notes.aggregate([
  { $group: { _id: "$noteType", totalNotes: { $sum: 1 } } }
]).forEach(doc => printjson(doc));
