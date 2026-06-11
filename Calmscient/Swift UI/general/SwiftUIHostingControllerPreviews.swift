//
//  SwiftUIHostingControllerPreviews.swift
//  Calmscient
//
//  Xcode #Preview entries for UIKit hosting controllers (SwiftUI roots embedded in UIViewController).
//
//  Vivek
//  14 May 2026
//
#if DEBUG
import SwiftUI
import UIKit

// MARK: - User profile (all supported iOS versions for this host)

private struct UserProfileHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UserProfileHostingController {
        UserProfileHostingController()
    }

    func updateUIViewController(_ uiViewController: UserProfileHostingController, context: Context) {}
}

#Preview("User profile host (UIKit)") {
    UserProfileHostingController_Previews()
}

// MARK: - Alarm settings sheet

private struct AlarmSettingsHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> AlarmSettingsHostingController {
        AlarmSettingsHostingController(initialAlarmMinutes: 15, delegate: nil)
    }

    func updateUIViewController(_ uiViewController: AlarmSettingsHostingController, context: Context) {}
}

#Preview("Alarm settings host (UIKit)") {
    AlarmSettingsHostingController_Previews()
}

// MARK: - iOS 16+ hosts

@available(iOS 16.0, *)
private struct LoginHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> LoginHostingController {
        LoginHostingController()
    }

    func updateUIViewController(_ uiViewController: LoginHostingController, context: Context) {}
}

@available(iOS 16.0, *)
private struct HomeDashboardHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> HomeDashboardHostingController {
        HomeDashboardHostingController()
    }

    func updateUIViewController(_ uiViewController: HomeDashboardHostingController, context: Context) {}
}

@available(iOS 16.0, *)
private struct ForgotPasswordHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ForgotPasswordHostingController {
        ForgotPasswordHostingController()
    }

    func updateUIViewController(_ uiViewController: ForgotPasswordHostingController, context: Context) {}
}

@available(iOS 16.0, *)
private struct CheckMailHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CheckMailHostingController {
        CheckMailHostingController(email: "preview@example.com")
    }

    func updateUIViewController(_ uiViewController: CheckMailHostingController, context: Context) {}
}

@available(iOS 16.0, *)
private struct UpdatePasswordHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UpdatePasswordHostingController {
        UpdatePasswordHostingController(email: "preview@example.com")
    }

    func updateUIViewController(_ uiViewController: UpdatePasswordHostingController, context: Context) {}
}

@available(iOS 16.0, *)
private struct LicenseValidationHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> LicenseValidationHostingController {
        LicenseValidationHostingController()
    }

    func updateUIViewController(_ uiViewController: LicenseValidationHostingController, context: Context) {}
}

@available(iOS 16.0, *)
private struct DayFeedbackHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DayFeedbackHostingController {
        DayFeedbackHostingController()
    }

    func updateUIViewController(_ uiViewController: DayFeedbackHostingController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Login host (UIKit)") {
    LoginHostingController_Previews()
}

@available(iOS 16.0, *)
#Preview("Home dashboard host (UIKit)") {
    HomeDashboardHostingController_Previews()
}

@available(iOS 16.0, *)
private struct WeeklySummaryDashboardHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> WeeklySummaryDashboardHostingController {
        WeeklySummaryDashboardHostingController()
    }

    func updateUIViewController(_ uiViewController: WeeklySummaryDashboardHostingController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Weekly summary dashboard host (UIKit)") {
    WeeklySummaryDashboardHostingController_Previews()
}

@available(iOS 16.0, *)
private struct WeeklySummaryGraphHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> WeeklySummaryGraphHostingController {
        let host = WeeklySummaryGraphHostingController()
        host.configure(summaryType: .WeeklySummarySummaryOfMood)
        return host
    }

    func updateUIViewController(_ uiViewController: WeeklySummaryGraphHostingController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Weekly summary graph host (UIKit)") {
    WeeklySummaryGraphHostingController_Previews()
}

@available(iOS 16.0, *)
private struct ProgressOnCourseWorkHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ProgressOnCourseWorkHostingController {
        ProgressOnCourseWorkHostingController()
    }

    func updateUIViewController(_ uiViewController: ProgressOnCourseWorkHostingController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Progress on course work host (UIKit)") {
    ProgressOnCourseWorkHostingController_Previews()
}

@available(iOS 16.0, *)
private struct ProgressOnCourseWorkDetailHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ProgressOnCourseWorkDetailHostingController {
        let host = ProgressOnCourseWorkDetailHostingController()
        host.configure(
            courses: CourseProgressPresentationPreviewData.sampleCourses,
            selectedIndex: 0
        )
        return host
    }

    func updateUIViewController(_ uiViewController: ProgressOnCourseWorkDetailHostingController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Progress on course work detail host (UIKit)") {
    ProgressOnCourseWorkDetailHostingController_Previews()
}

@available(iOS 16.0, *)
#Preview("Forgot password host (UIKit)") {
    ForgotPasswordHostingController_Previews()
}

@available(iOS 16.0, *)
#Preview("Check mail host (UIKit)") {
    CheckMailHostingController_Previews()
}

@available(iOS 16.0, *)
#Preview("Update password host (UIKit)") {
    UpdatePasswordHostingController_Previews()
}

@available(iOS 16.0, *)
#Preview("License validation host (UIKit)") {
    LicenseValidationHostingController_Previews()
}

@available(iOS 16.0, *)
#Preview("Day feedback host (UIKit)") {
    DayFeedbackHostingController_Previews()
}

@available(iOS 16.0, *)
private struct PatientProfileEditHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> PatientProfileEditHostingController {
        PatientProfileEditHostingController()
    }

    func updateUIViewController(_ uiViewController: PatientProfileEditHostingController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Patient profile edit host (UIKit)") {
    PatientProfileEditHostingController_Previews()
}

@available(iOS 16.0, *)
private struct UserMedicalRecordsHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UserMedicalRecordsHostingController {
        UserMedicalRecordsHostingController()
    }

    func updateUIViewController(_ uiViewController: UserMedicalRecordsHostingController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Medical records host (UIKit)") {
    UserMedicalRecordsHostingController_Previews()
}

@available(iOS 16.0, *)
private struct DiscoveryMainHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DiscoveryMainHostingController {
        DiscoveryMainHostingController()
    }

    func updateUIViewController(_ uiViewController: DiscoveryMainHostingController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Discovery main host (UIKit)") {
    DiscoveryMainHostingController_Previews()
}

@available(iOS 16.0, *)
private struct ManagingAnxietyBeginHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ManagingAnxietyBeginHostingController {
        ManagingAnxietyBeginHostingController()
    }

    func updateUIViewController(_ uiViewController: ManagingAnxietyBeginHostingController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Managing anxiety begin host (UIKit)") {
    ManagingAnxietyBeginHostingController_Previews()
}

@available(iOS 16.0, *)
private struct UserMedicationsHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UserMedicationsHostingController {
        UserMedicationsHostingController()
    }

    func updateUIViewController(_ uiViewController: UserMedicationsHostingController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Medications host (UIKit)") {
    UserMedicationsHostingController_Previews()
}

@available(iOS 16.0, *)
private struct NextAppointmentsHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> NextAppointmentsHostingController {
        NextAppointmentsHostingController()
    }

    func updateUIViewController(_ uiViewController: NextAppointmentsHostingController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Next appointments host (UIKit)") {
    NextAppointmentsHostingController_Previews()
}

@available(iOS 16.0, *)
private struct ScreeningListHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ScreeningListHostingController {
        ScreeningListHostingController()
    }

    func updateUIViewController(_ uiViewController: ScreeningListHostingController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Screening list host (UIKit)") {
    ScreeningListHostingController_Previews()
}

@available(iOS 16.0, *)
private struct HistoryHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> HistoryHostingController {
        let host = HistoryHostingController()
        if let screening = ScreeningRowPresentationPreviewData.sample(type: "PHQ-9")?.screening {
            host.configure(selectedScreening: screening)
        }
        return host
    }

    func updateUIViewController(_ uiViewController: HistoryHostingController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("History host (UIKit)") {
    HistoryHostingController_Previews()
}

@available(iOS 16.0, *)
private struct JournalEntryHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> JournalEntryHostingController {
        JournalEntryHostingController()
    }

    func updateUIViewController(_ uiViewController: JournalEntryHostingController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Journal entry host (UIKit)") {
    JournalEntryHostingController_Previews()
}

@available(iOS 16.0, *)
private struct ScreeningQuestionsHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = ScreeningQuestionsHostingController()
        if let screening = ScreeningRowPresentationPreviewData.sample(type: "PHQ-9")?.screening {
            host.configure(selectedScreening: screening)
        }
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Screening questions host (UIKit)") {
    ScreeningQuestionsHostingController_Previews()
}

@available(iOS 16.0, *)
private struct ScreeningResultHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = ScreeningResultHostingController()
        if let screening = ScreeningRowPresentationPreviewData.sample(type: "PHQ-9")?.screening {
            host.configure(selectedScreening: screening)
        }
        if let result = ScreeningResultPresentationPreviewData.sample() {
            host.viewModel.applyPreviewState(result: result)
        }
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Screening results host (UIKit)") {
    ScreeningResultHostingController_Previews()
}

@available(iOS 16.0, *)
private struct MedicationsDetailHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let json = """
        {
          "date": "05/14/2026",
          "medicationDetailsByDate": [
            {
              "medicineName": "Preview Med",
              "numberOfTablets": 1,
              "dosageTime": [],
              "medicalDetails": {
                "medicationId": 1,
                "medicineName": "Preview Med",
                "medicineDosage": "10mg",
                "providerName": "Dr. Preview",
                "prescriptionID": 1,
                "providerId": 1,
                "directions": "Once daily",
                "scheduledTimeList": [
                  {
                    "scheduledTimes": [
                      {
                        "medicineTime": "08:00:00",
                        "alarmTime": "2026-05-14 08:00:00",
                        "alarmId": 1,
                        "pmtId": "1",
                        "medicineTaken": "0",
                        "alarmEnabled": "1",
                        "alarmInterval": "05",
                        "repeat": ["Mon"],
                        "isDefault": 0
                      }
                    ]
                  }
                ],
                "withMeal": 0,
                "endDate": "12/31/2026",
                "expired": 0
              }
            }
          ]
        }
        """
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        guard let md = try? decoder.decode(MedicineDetails.self, from: data) else {
            return UIViewController()
        }
        let detail = MedicationsDetailHostingController(medicineDetails: md)
        return UINavigationController(rootViewController: detail)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Medication detail host (UIKit)") {
    MedicationsDetailHostingController_Previews()
}

@available(iOS 16.0, *)
private struct AddUserMedicationsHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let json = """
        {
          "date": "05/14/2026",
          "medicationDetailsByDate": [
            {
              "medicineName": "Preview Med",
              "numberOfTablets": 1,
              "dosageTime": [],
              "medicalDetails": {
                "medicationId": 1,
                "medicineName": "Preview Med",
                "medicineDosage": "10mg",
                "providerName": "Dr. Preview",
                "prescriptionID": 1,
                "providerId": 1,
                "directions": "Once daily with water",
                "scheduledTimeList": [
                  {
                    "scheduledTimes": [
                      {
                        "medicineTime": "08:00:00",
                        "alarmTime": "2026-05-14 08:00:00",
                        "alarmId": 1,
                        "pmtId": "1",
                        "medicineTaken": "0",
                        "alarmEnabled": "1",
                        "alarmInterval": "05",
                        "repeat": ["Mon"],
                        "isDefault": 0
                      }
                    ]
                  }
                ],
                "withMeal": 1,
                "endDate": "05/22/2026",
                "expired": 0
              }
            }
          ]
        }
        """
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        guard let md = try? decoder.decode(MedicineDetails.self, from: data) else {
            return UIViewController()
        }
        let vm = AddEditMedicationViewModel(isEditMode: true, medicationData: md, refreshControlClosure: nil)
        let add = AddUserMedicationsViewController(viewModel: vm)
        add.title = "Edit medications"
        return UINavigationController(rootViewController: add)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Add / edit medications host (UIKit)") {
    AddUserMedicationsHostingController_Previews()
}

// MARK: - Add new appointment

private struct AddNewAppointmentHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = AddNewAppointmentHostingController(isEditMode: false, editPayload: nil)
        host.title = "Add appointment"
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

#Preview("Add appointment host (UIKit)") {
    AddNewAppointmentHostingController_Previews()
}

// MARK: - Appointment details

@available(iOS 16.0, *)
private struct AppointmentDetailsHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let json = """
        {
          "hospitalName": "Central Park Hospital",
          "appointmentDetails": {
            "appointmentId": 1,
            "providerName": "Dr. Samuel Parker",
            "hospitalName": "Hyderabad",
            "dateAndTime": "2026-05-16 14:30:00",
            "contact": "(804) 093 8172",
            "address": "South Frederic Av 489",
            "appointmentDetails": "Description",
            "alert": 0
          }
        }
        """
        let data = Data(json.utf8)
        guard let appointment = try? JSONDecoder().decode(MedicalAppointmentDetailsByDate.self, from: data) else {
            return UIViewController()
        }
        let detail = AppointmentDetailsHostingController(medicalAppointment: appointment)
        return UINavigationController(rootViewController: detail)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Appointment details host (UIKit)") {
    AppointmentDetailsHostingController_Previews()
}

@available(iOS 16.0, *)
private struct CitationWebHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        UINavigationController(rootViewController: CitationWebHostingController())
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Citation web host (UIKit)") {
    CitationWebHostingController_Previews()
}

// MARK: - Courses

@available(iOS 16.0, *)
private struct CoursesHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = CoursesHostingController()
        host.configure(courseID: 2, navigationTitle: "Managing anxiety")
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Courses host (UIKit)") {
    CoursesHostingController_Previews()
}

@available(iOS 16.0, *)
private struct GlossaryHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = GlossaryHostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Glossary host (UIKit)") {
    GlossaryHostingController_Previews()
}

@available(iOS 16.0, *)
private struct WebViewLessonHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = WebViewLessonHostingController(
            presentation: WebViewLessonPresentationPreviewData.sampleManagingAnxiety
        )
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Web lesson host (UIKit)") {
    WebViewLessonHostingController_Previews()
}

@available(iOS 16.0, *)
private struct TakingControlIntroHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = TakingControlIntroHostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Taking control intro host (UIKit)") {
    TakingControlIntroHostingController_Previews()
}

@available(iOS 16.0, *)
private struct TakingControlIntroSecondHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = TakingControlIntroSecondHostingController()
        host.configure(auditData: [], dastData: [])
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Taking control intro second host (UIKit)") {
    TakingControlIntroSecondHostingController_Previews()
}

@available(iOS 16.0, *)
private struct TakingIntroLastHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = TakingIntroLastHostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Taking intro last host (UIKit)") {
    TakingIntroLastHostingController_Previews()
}

@available(iOS 16.0, *)
private struct TakingControlIndexHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = TakingControlIndexHostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Taking control index host (UIKit)") {
    TakingControlIndexHostingController_Previews()
}

@available(iOS 16.0, *)
private struct FullComingSoonHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> FullComingSoonHostingController {
        FullComingSoonHostingController()
    }

    func updateUIViewController(_ uiViewController: FullComingSoonHostingController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Full coming soon host (UIKit)") {
    FullComingSoonHostingController_Previews()
}

@available(iOS 16.0, *)
private struct QuitSymptomModalHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> QuitSymptomModalHostingController {
        QuitSymptomModalHostingController(topic: .nicotineCravings)
    }

    func updateUIViewController(_ uiViewController: QuitSymptomModalHostingController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Quit symptom modal host (UIKit)") {
    QuitSymptomModalHostingController_Previews()
}

private struct BreathingTechniqueHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = BreathingTechniqueHostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

#Preview("Breathing technique host (UIKit)") {
    BreathingTechniqueHostingController_Previews()
}

@available(iOS 16.0, *)
private struct ExercisesHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = ExercisesHostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Exercises host (UIKit)") {
    ExercisesHostingController_Previews()
}

@available(iOS 16.0, *)
private struct MindfulnessHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = MindfulnessHostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Mindfulness host (UIKit)") {
    MindfulnessHostingController_Previews()
}

@available(iOS 16.0, *)
private struct ProgressiveHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = ProgressiveHostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Progressive host (UIKit)") {
    ProgressiveHostingController_Previews()
}

@available(iOS 16.0, *)
private struct TouchButterflyIntroHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = TouchButterflyIntroHostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Touch butterfly intro host (UIKit)") {
    TouchButterflyIntroHostingController_Previews()
}

@available(iOS 16.0, *)
private struct TouchButterflyHowToHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = TouchButterflyHowToHostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Touch butterfly how-to host (UIKit)") {
    TouchButterflyHowToHostingController_Previews()
}

@available(iOS 16.0, *)
private struct HandOverYourHeartHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = HandOverYourHeartHostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Hand over your heart host (UIKit)") {
    HandOverYourHeartHostingController_Previews()
}

@available(iOS 16.0, *)
private struct MindfulWalkingHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = MindfulWalkingHostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Mindful walking host (UIKit)") {
    MindfulWalkingHostingController_Previews()
}

@available(iOS 16.0, *)
private struct MovementDanceHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = MovementDanceHostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Movement dance host (UIKit)") {
    MovementDanceHostingController_Previews()
}

@available(iOS 16.0, *)
private struct MovementRunningHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = MovementRunningHostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Movement running host (UIKit)") {
    MovementRunningHostingController_Previews()
}

@available(iOS 16.0, *)
private struct MindfulBodyMovementHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = MindfulBodyMovementHostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Mindful body movement host (UIKit)") {
    MindfulBodyMovementHostingController_Previews()
}

@available(iOS 16.0, *)
private struct BreathingTechniqueType1HostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = BreathingTechniqueType1HostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("4-7-8 breathing host (UIKit)") {
    BreathingTechniqueType1HostingController_Previews()
}

@available(iOS 16.0, *)
private struct MindfulBreathingHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = MindfulBreathingHostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Mindful breathing host (UIKit)") {
    MindfulBreathingHostingController_Previews()
}

@available(iOS 16.0, *)
private struct DiaphragmaticBreathingHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = DiaphragmaticBreathingHostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Diaphragmatic breathing host (UIKit)") {
    DiaphragmaticBreathingHostingController_Previews()
}

@available(iOS 16.0, *)
private struct DrinkingCountHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = DrinkingCountHostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Drink counts calculator host (UIKit)") {
    DrinkingCountHostingController_Previews()
}

@available(iOS 16.0, *)
private struct BasicKnowledgeHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = BasicKnowledgeHostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Basic knowledge host (UIKit)") {
    BasicKnowledgeHostingController_Previews()
}

@available(iOS 16.0, *)
private struct SmokingBasicKnowledgeHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = SmokingBasicKnowledgeHostingController()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Smoking basic knowledge host (UIKit)") {
    SmokingBasicKnowledgeHostingController_Previews()
}

@available(iOS 16.0, *)
private struct BasicStandardDrinkHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = BasicStandardDrinkHostingController()
        host.viewModel.applyPreviewState(items: StandardDrinkCarouselItemPresentation.previewItems())
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Standard drink host (UIKit)") {
    BasicStandardDrinkHostingController_Previews()
}

@available(iOS 16.0, *)
private struct USGuideLineForDrinkingHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = USGuideLineForDrinkingHostingController()
        host.viewModel.applyPreviewState()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("U.S. guidelines host (UIKit)") {
    USGuideLineForDrinkingHostingController_Previews()
}

@available(iOS 16.0, *)
private struct ModerationHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = ModerationHostingController()
        host.viewModel.applyPreviewState()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Moderation host (UIKit)") {
    ModerationHostingController_Previews()
}

@available(iOS 16.0, *)
private struct HoldYourLiquorHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = HoldYourLiquorHostingController()
        host.viewModel.configure(sectionId: 7)
        host.viewModel.applyPreviewState()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Hold your liquor host (UIKit)") {
    HoldYourLiquorHostingController_Previews()
}

@available(iOS 16.0, *)
private struct TobaccoHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = TobaccoHostingController()
        host.viewModel.configure(sectionId: 1)
        host.viewModel.applyPreviewState()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Tobacco host (UIKit)") {
    TobaccoHostingController_Previews()
}

@available(iOS 16.0, *)
private struct ChallengingToQuitHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = ChallengingToQuitHostingController()
        host.viewModel.configure(sectionId: 4)
        host.viewModel.applyPreviewState()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Challenging to quit host (UIKit)") {
    ChallengingToQuitHostingController_Previews()
}

@available(iOS 16.0, *)
private struct VapingHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = VapingHostingController()
        host.viewModel.configure(sectionId: 2)
        host.viewModel.applyPreviewState()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Vaping host (UIKit)") {
    VapingHostingController_Previews()
}

@available(iOS 16.0, *)
private struct SmokingRelaxHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = SmokingRelaxHostingController()
        host.viewModel.configure(sectionId: 3)
        host.viewModel.applyPreviewState()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Smoking relax host (UIKit)") {
    SmokingRelaxHostingController_Previews()
}

@available(iOS 16.0, *)
private struct SmokingAffectMentalHealthHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = SmokingAffectMentalHealthHostingController()
        host.viewModel.configure(sectionId: 5)
        host.viewModel.applyPreviewState()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Smoking mental health host (UIKit)") {
    SmokingAffectMentalHealthHostingController_Previews()
}

@available(iOS 16.0, *)
private struct MyDrinkingHabitHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = MyDrinkingHabitHostingController()
        host.viewModel.configure(sectionId: 6)
        host.viewModel.applyPreviewState(selectedIndex: 0)
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("My drinking habit host (UIKit)") {
    MyDrinkingHabitHostingController_Previews()
}

@available(iOS 16.0, *)
private struct MySmokingHabitHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = MySmokingHabitHostingController()
        host.viewModel.configure(sectionId: 6)
        host.viewModel.applyPreviewState(selectedIndex: 0)
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("My smoking habit host (UIKit)") {
    MySmokingHabitHostingController_Previews()
}

@available(iOS 16.0, *)
private struct ModerateDrinkingEducationHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = ModerateDrinkingEducationHostingController()
        host.viewModel.configure(variant: .moderateDrinking, sectionId: 6)
        host.viewModel.applyPreviewState()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Moderate drinking education host (UIKit)") {
    ModerateDrinkingEducationHostingController_Previews()
}

@available(iOS 16.0, *)
private struct ConsequenceHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = ConsequenceHostingController()
        host.viewModel.configure(sectionId: 5)
        host.viewModel.applyPreviewState()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Consequences index host (UIKit)") {
    ConsequenceHostingController_Previews()
}

@available(iOS 16.0, *)
private struct ConSub1HostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = ConSub1HostingController()
        host.viewModel.applyPreviewState()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("ConSub1 fatalities host (UIKit)") {
    ConSub1HostingController_Previews()
}

@available(iOS 16.0, *)
private struct ConSub2HostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = ConSub2HostingController()
        host.viewModel.applyPreviewState()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("ConSub2 mental dysfunction host (UIKit)") {
    ConSub2HostingController_Previews()
}

@available(iOS 16.0, *)
private struct ConSub3HostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = ConSub3HostingController()
        host.viewModel.applyPreviewState()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("ConSub3 blackouts host (UIKit)") {
    ConSub3HostingController_Previews()
}

@available(iOS 16.0, *)
private struct ConSub4HostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = ConSub4HostingController()
        host.viewModel.applyPreviewState()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("ConSub4 health problems host (UIKit)") {
    ConSub4HostingController_Previews()
}

@available(iOS 16.0, *)
private struct ConSub5HostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = ConSub5HostingController()
        host.viewModel.applyPreviewState()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("ConSub5 AUD host (UIKit)") {
    ConSub5HostingController_Previews()
}

@available(iOS 16.0, *)
private struct BasicKnowledgeVideoHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let host = BasicKnowledgeVideoHostingController()
        host.viewModel.configure(sectionId: 4)
        host.viewModel.applyPreviewState()
        return UINavigationController(rootViewController: host)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Brain video host (UIKit)") {
    BasicKnowledgeVideoHostingController_Previews()
}

@available(iOS 16.0, *)
private struct LaunchScreenHostingController_Previews: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> LaunchScreenHostingController {
        LaunchScreenHostingController()
    }

    func updateUIViewController(_ uiViewController: LaunchScreenHostingController, context: Context) {}
}

@available(iOS 16.0, *)
#Preview("Launch screen host (UIKit)") {
    LaunchScreenHostingController_Previews()
}

#endif
