export default function DashboardPage() {
  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold text-gray-800 mb-8">대시보드</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard title="오늘 가입" value="-" color="blue" />
        <StatCard title="활성 유저" value="-" color="green" />
        <StatCard title="접수 문의" value="-" color="amber" />
        <StatCard title="미처리 제보" value="-" color="red" />
      </div>
      <div className="mt-8 p-6 bg-white rounded-lg shadow">
        <h2 className="text-lg font-semibold text-gray-800 mb-4">
          빠른 액션
        </h2>
        <p className="text-gray-500 text-sm">
          API 연동 후 데이터가 표시됩니다.
        </p>
      </div>
    </div>
  );
}

function StatCard({
  title,
  value,
  color,
}: {
  title: string;
  value: string;
  color: "blue" | "green" | "amber" | "red";
}) {
  const colors = {
    blue: "border-l-blue-500",
    green: "border-l-green-500",
    amber: "border-l-amber-500",
    red: "border-l-red-500",
  };
  return (
    <div className={`bg-white rounded-lg shadow p-6 border-l-4 ${colors[color]}`}>
      <p className="text-sm text-gray-500">{title}</p>
      <p className="text-2xl font-bold text-gray-800 mt-1">{value}</p>
    </div>
  );
}
