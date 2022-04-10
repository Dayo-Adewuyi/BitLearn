import '../styles/globals.css'
import Link from 'next/link'

function MyApp({ Component, pageProps }) {
  return (
    <div >
      <nav className="bg-slate-200 border-b p-6">
        <p className="flex items-center space-x-2 text-4xl font-medium text-indigo-500 dark:text-gray-100npm ">BitLearn </p>
        <div className="flex mt-4"></div>
        <Link href="/">
          <a className="mr-4 text-blue-500">HOME</a>
        </Link>
        <Link href="/all-courses">
          <a className="mr-4 text-blue-500">ALL COURSES</a>
        </Link>
        <Link href="/create-item">
          <a className="mr-6 text-blue-500">CREATE A COURSE</a>
        </Link>
        <Link href="/my-assets">
          <a className="mr-6 text-blue-500">MY COURSES</a>
        </Link>
        <Link href="/creator-dashboard">
          <a className="mr-6 text-blue-500">TUTOR'S CORNER</a>
        </Link>
      </nav> 
      <Component {...pageProps} />
    </div>
  
  )
}

export default MyApp
