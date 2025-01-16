//
//  CoursesTableViewCell.swift
//  CalmscientIOS
//
//  Created by KA on NA.
//

import UIKit
import Alamofire
import AlamofireImage

class CoursesTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var courseChapterCollectionView: UICollectionView!
    weak var courseDateItem:CourseLesson? = nil
    var courseSelectionClosure:((String,String,String) -> Void)?
    var courseName : String?
    var typeOfPage : String?
    var languageName = ""
    var darkTheme = 0
    var userSessionID = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        let nib = UINib(nibName: "CoursesCollectionViewCell", bundle: nil)
        courseChapterCollectionView.backgroundColor = UIColor(named: "AppBackGroundColor")
        courseChapterCollectionView.register(nib, forCellWithReuseIdentifier: "CoursesCollectionViewCell")
        courseChapterCollectionView.delegate = self
        courseChapterCollectionView.dataSource = self
        if let layout = courseChapterCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        courseChapterCollectionView.contentInset = .zero
        courseChapterCollectionView.showsHorizontalScrollIndicator = false
        courseChapterCollectionView.showsVerticalScrollIndicator = false
        courseChapterCollectionView.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func updateTableCell(data:CourseLesson) {
        self.courseDateItem = data
        titleLabel.text = data.lessonName
        courseChapterCollectionView.reloadData()
    }
    
}

extension CoursesTableViewCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return courseDateItem?.chapters.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoursesCollectionViewCell", for: indexPath) as? CoursesCollectionViewCell, let course = courseDateItem else {
            return UICollectionViewCell()
        }
        AF.request(course.chapters[indexPath.row].imageUrl).responseImage { response in
          if case .success(let image) = response.result {
              cell.courseImageView.image = image
              cell.courseImageView.contentMode = .scaleAspectFill
              cell.courseImageView.layer.cornerRadius = 3
              cell.courseImageView.layer.masksToBounds = true
              print("course.chapters[indexPath.row].isCourseCompleted \(course.chapters[indexPath.row].isCourseCompleted)")
              if course.chapters[indexPath.row].isCourseCompleted == 0 {
                  cell.tickMarkImage.isHidden = true
              } else {
                  cell.tickMarkImage.isHidden = false
              }
              cell.titleLabel.isHidden = false
              cell.titleLabel.text = course.chapters[indexPath.row].chapterName
              if(self.courseName == "managingAnxiety"){
                  cell.titleLabel.textColor = .white
              }else{
                  cell.titleLabel.textColor = UIColor(named: "AppThemeColor")
              }
              
          }
        }
       return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Return the size of each item in your collection view
        let height = collectionView.frame.height
        return CGSize(width: 172, height: 120)//height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let course = courseDateItem else {
            return
        }
        let selectedLesson = course.chapters[indexPath.row]
        
        guard let courseName = courseName else { return }
        let urlString = prepareWebViewLessonURL(lesson: selectedLesson, course: course, courseName1: courseName,languageName: languageName,darkTheme: darkTheme)
                courseSelectionClosure?(urlString, selectedLesson.chapterName, courseName)
    }
    
    private func prepareWebViewLessonURL(lesson:CourseChapter, course:CourseLesson, courseName1: String , languageName: String, darkTheme: Int) -> String {
        let language = String(languageName.prefix(2)).lowercased()
        
        let darkThemeValue = darkTheme == 0 ? false : true
        let courseURLString = "http://20.197.5.97:5000/?courseName=\(courseName1)&lessonId=\(course.lessonId)&chapterId=\(lesson.chapterId)&language=\(language)&darkMode=\(darkThemeValue)"
        print(courseURLString)
        return courseURLString
    }
}
