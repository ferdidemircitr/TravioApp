//
//  MapVC.swift
//  Travio
//
//  Created by Ferdi DEMİRCİ on 31.08.2023.
//

import UIKit
import MapKit
import SnapKit

protocol ReturnToMap: AnyObject {
    func returned()
}

class MapVC: UIViewController, MKMapViewDelegate{
    
    var viewModel = MapVM()
    var place = ""
    
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        return mapView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 18
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(MapCVC.self, forCellWithReuseIdentifier: MapCVC().identifier)
        return collectionView
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupData()
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView.addGestureRecognizer(longPressRecognizer)
    }
    
    private func setupViews(){
        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .systemBackground
        view.addSubviews(mapView, collectionView)
        setupLayout()
    }
    
    private func setupLayout(){
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-18)
            make.height.equalTo(178)
        }
    }
    
    func setupData() {
        viewModel.getData {
            self.collectionView.reloadData()
            for location in self.viewModel.mapPlaces {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            getAddressFromCoordinate(coordinate: coordinate) {
                let vc = AddVisitVC()
                vc.delegate = self
                vc.configure(place: self.place)
                vc.latitude = coordinate.latitude
                vc.longitude = coordinate.longitude
                self.present(vc, animated: true)
            }
        }
    }
    
    func getAddressFromCoordinate(coordinate: CLLocationCoordinate2D, complate: @escaping () -> Void){
        let geocoder = CLGeocoder()
           
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
           
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                return
            }
            if let placemark = placemarks?.first {
                if let street = placemark.thoroughfare,
                   let city = placemark.locality,
                    let country = placemark.country {
                    self.place = "\(city), \(country)"
                    complate()
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        if let pinImage = UIImage(named: "mapLocation") {
            let size = CGSize(width: 32, height: 42)
            
            UIGraphicsBeginImageContext(size)
            pinImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            annotationView?.image = resizedImage
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MKPointAnnotation {
            let coordinate = annotation.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: true)
            if let index = viewModel.mapPlaces.firstIndex(where: { $0.latitude == annotation.coordinate.latitude && $0.longitude == annotation.coordinate.longitude }) {
                let indexPath = IndexPath(item: index, section: 0)
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
    
}

extension MapVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: collectionView.frame.width - 60, height: 178)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.mapPlaces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MapCVC().identifier, for: indexPath) as? MapCVC else { return UICollectionViewCell() }
        cell.roundCorners(corners: [.topLeft, .topRight, .bottomLeft], radius: 16)
        cell.congigure(model: viewModel.mapPlaces[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let placeDetails = viewModel.mapPlaces[indexPath.row]
        let vc = CustomDetailsVC()
        vc.placeDetails = placeDetails
        vc.isVisitVC = false
        viewModel.getVisitByPlaceId(placeId: placeDetails.id) { status in
            if status {
                vc.isVisited = true
            } else {
                vc.isVisited = false
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
}

extension MapVC: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
           let cellWidthIncludingSpacing = collectionView.frame.size.width - 42
           
           var offset = targetContentOffset.pointee
           let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
           let roundedIndex = round(index)
           
           offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
           targetContentOffset.pointee = offset
       }
}

extension MapVC: ReturnToMap {
    func returned() {
        print("Map returned")
        setupData()
    }
}
